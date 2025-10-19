# --- Header -------------------------------------------------------------------
# Prepares the "Explore Discretionary Accruals" display
#
# (C) TRR 266 -  See LICENSE file for details
# ------------------------------------------------------------------------------

from itertools import product

from statsmodels.formula.api import ols
import numpy as np
import pandas as pd

from utils import read_config, setup_logging

log = setup_logging()
global_cfg = read_config('config/global_cfg.yaml')

def main():
    log.info("Preparing base sample ...")

    ff12 = pd.read_csv(global_cfg['fama_french_12'], dtype=object)
    ff48 = pd.read_csv(global_cfg['fama_french_48'], dtype=object)

    cstat_us_sample = pd.read_parquet(global_cfg['cstat_us_parquet_file'])
    cstat_us_sample['gvkey'] = cstat_us_sample['gvkey'].astype(str)
    
    numeric_cols = [
        'fyear', 'at', 'sale', 'ibc', 'oancf', 'ppegt', 'recch', 
        'invch', 'apalch', 'txach', 'aoloch', 'csho', 'prcc_f',
        'ceq', 'lt', 'ppent', 'intan', 'gdwl', 'aqs', 'acqsc',
        'cogs', 'ib', 'xint'
    ]
    for col in numeric_cols:
        if col in cstat_us_sample.columns:
            cstat_us_sample[col] = pd.to_numeric(cstat_us_sample[col], errors='coerce')

    us_base_sample = prep_us_base_sample(cstat_us_sample, ff12, ff48)

    dup_obs = us_base_sample[us_base_sample.duplicated()]
    assert dup_obs.shape[0] == 0, "Duplicate firm-year observations in Compustat data, stored in 'dup_obs'."

    log.info("Calculating modified Jones discretionary accruals ...")
    mj = estimate_mj_accruals(us_base_sample)

    log.info("Calculating Dechow and Dichev discretionary accruals ...")
    dd = estimate_dd_accruals(us_base_sample)

    log.info("Merging data and preparing final sample ...")
    np.seterr(divide='ignore')  # because np.log(0) throws a warning
    smp = prep_smp(us_base_sample, mj, dd)
    np.seterr(divide='warn')

    smp.to_parquet(global_cfg['acc_sample'], index=False)
    log.info(f"Final sample saved to '{global_cfg['acc_sample']}'.")


def prep_us_base_sample(df, ff12, ff48):
    df = df.astype({'sic': 'Int64', 'sich': 'Int64'})
    df = (df
          .assign(sic=lambda x: x["sich"].fillna(x["sic"]))
          .query('indfmt == "INDL" & fic == "USA" & at.notna() & at > 0 & sale > 0')
          .query('sic < 6000 | sic > 6999')
          .query('sic.notna()')
          .assign(sic=lambda x: x['sic'].astype(str).str.zfill(4))
          .merge(ff48, how="left", on="sic")
          .merge(ff12, how="left", on="sic")
          .query('ff48_ind.notna() & ff12_ind.notna()')
          .sort_values(["gvkey", "fyear"])
          )
    return df

# --- Calculate modified Jones model accruals and statistics -------------------

# Methodology is somewhat loosely based on Hribar and Nichols (JAR, 2007)
# https://doi.org/10.1111/j.1475-679X.2007.00259.x


def estimate_mj_accruals(df, min_obs=10):
    df = (df
          .assign(
              lagta=lambda x: np.concatenate(
                  [mleadlag(df['at'], -1, df['fyear']) for _, df in groupby(x, 'gvkey')]),
              tacc=lambda x: groupby(x, 'gvkey').apply(
                  lambda x: (x['ibc'] - x['oancf'])/x['lagta'], include_groups=False),
              drev=lambda x: np.concatenate(
                  [(df['sale'] - mleadlag(df['sale'], -1, df['fyear']) + df['recch'])/df['lagta'] for _, df in groupby(x, 'gvkey')]),
              inverse_a=lambda x: groupby(
                  x, 'gvkey').apply(lambda x: 1/x['lagta'], include_groups=False),
              ppe=lambda x: groupby(x, 'gvkey').apply(
                  lambda x: x['ppegt']/x['lagta'], include_groups=False))
          .query('tacc.notna() & drev.notna() & ppe.notna()')
          .filter(["gvkey", "ff48_ind", "fyear", "tacc", "drev", "inverse_a", "ppe"])
          .groupby(['ff48_ind', 'fyear'])
          .filter(lambda x: x['fyear'].count() >= min_obs)
          .pipe(winsorize, drop="fyear")
          )

    model_df = pd.DataFrame(
        df.groupby(['ff48_ind', 'fyear']).apply(
            lambda x: pd.Series(
                {'gvkey': x['gvkey'], 'model': accrual_model_mjones(x)}
            ), include_groups=False)
    )

    mj_resids = (model_df
                 .assign(mj_da=lambda x: x['model']
                         .apply(lambda y: pd.Series([y.resid])))
                 .filter(['gvkey', 'mj_da'])
                 .apply(pd.Series.explode)
                 .reset_index()
                 )

    mj_adjr2s = pd.DataFrame(model_df['model'].apply(
        lambda x: pd.Series({'mj_nobs': x.nobs, 'mj_adjr2': x.rsquared_adj}))).reset_index()

    mj_coefs = (pd.DataFrame(model_df['model'].apply(lambda x: x.params))
                .rename(columns={c: 'mj_' + c.lower() for c in ['Intercept', 'inverse_a', 'drev', 'ppe']})
                .reset_index()
                )

    mj = (mj_resids
          .merge(mj_adjr2s, how="left", on=["ff48_ind", "fyear"])
          .merge(mj_coefs, how="left", on=["ff48_ind", "fyear"]))

    return mj

# --- Calculate Dechow/Dichev accruals and statistics --------------------------

# Methodology is based on Dechow and Dichev (TAR, 2002)
# https://doi.org/10.2308/accr.2002.77.s-1.35


def estimate_dd_accruals(df, min_obs=10):
    df = (df
          .assign(
              avgta=lambda x: np.concatenate(
                  [(df['at'] + mleadlag(df['at'], -1, df['fyear']))/2 for _, df in groupby(x, 'gvkey')]),
              cfo=lambda x: groupby(x, 'gvkey').apply(
                  lambda x: x['oancf']/x['avgta'], include_groups=False),
              lagcfo=lambda x: np.concatenate(
                  [mleadlag(df['cfo'], -1, df['fyear']) for _, df in groupby(x, 'gvkey')]),
              leadcfo=lambda x: np.concatenate(
                  [mleadlag(df['cfo'], +1, df['fyear']) for _, df in groupby(x, 'gvkey')]),
              dwc=lambda x: groupby(x, 'gvkey').apply(
                  lambda x: -(x['recch'] + x['invch'] + x['apalch'] + x['txach'] + x['aoloch'])/x['avgta'], include_groups=False))
          .query('dwc.notna() & cfo.notna() & lagcfo.notna() & leadcfo.notna()')
          .filter(["gvkey", "ff48_ind", "fyear", "dwc", "cfo", "lagcfo", "leadcfo"])
          .groupby(['ff48_ind', 'fyear'])
          .filter(lambda x: x['fyear'].count() >= min_obs)
          .pipe(winsorize, drop="fyear")
          )

    model_df = pd.DataFrame(
        df.groupby(['ff48_ind', 'fyear']).apply(lambda x: pd.Series(
            {'gvkey': x['gvkey'], 'model': accrual_model_dd(x)}
        ), include_groups=False)
    )

    dd_resids = (model_df
                 .assign(dd_da=lambda x: x['model']
                         .apply(lambda y: pd.Series([y.resid])))
                 .filter(['gvkey', 'dd_da'])
                 .apply(pd.Series.explode)
                 .reset_index()
                 )

    dd_adjr2s = pd.DataFrame(model_df['model'].apply(
        lambda x: pd.Series({'dd_nobs': x.nobs, 'dd_adjr2': x.rsquared_adj}))).reset_index()

    dd_coefs = (pd.DataFrame(model_df['model'].apply(lambda x: x.params))
                .rename(columns={c: 'dd_' + c.lower() for c in ['Intercept', 'lagcfo', 'cfo', 'leadcfo']})
                .reset_index()
                )

    dd = (dd_resids
          .merge(dd_adjr2s, how="left", on=["ff48_ind", "fyear"])
          .merge(dd_coefs, how="left", on=["ff48_ind", "fyear"]))

    return dd


def accrual_model_mjones(df):
    return ols('tacc ~ inverse_a + drev + ppe', df).fit()


def accrual_model_dd(df):
    return ols('dwc ~ lagcfo + cfo + leadcfo', df).fit()


def mleadlag(x, n, ts_id):
    return np.where(ts_id == ts_id.shift(-n) - n, x.shift(-n), np.nan)


def groupby(x, by):
    return x.groupby(by, group_keys=False)


def treat_vector_outliers(x, percentile=0.01, truncate=False):
    '''
    Treats numerical outliers either by winsorizing or by truncating.
    '''

    if not np.issubdtype(x.dtype, np.number):
        return x

    x = np.array(x, copy=True)

    lim = np.quantile(x, [percentile, 1-percentile])

    if truncate:
        x[x < lim[0]] = np.nan
        x[x > lim[1]] = np.nan
    else:
        x[x < lim[0]] = lim[0]
        x[x > lim[1]] = lim[1]
    return x


def treat_outliers(df, percentile=0.01, truncate=False, by=None):
    if by:
        return groupby(df, by).apply(lambda sub_group: sub_group.apply(lambda x: treat_vector_outliers(x, percentile, truncate)))
    else:
        return df.apply(lambda x: treat_vector_outliers(x, percentile, truncate))


def winsorize(df, drop=None, **kwargs):
    '''
    Treats the outliers of all numerical columns in df, except the ones in drop.
    '''

    if drop:
        _vars = [c for c in list(df) if c not in drop]
        df.loc[:, _vars] = treat_outliers(df.loc[:, _vars], **kwargs)
    else:
        df = treat_outliers(df, **kwargs)
    return df


def prep_smp(us_base_sample, mj, dd):
    smp = expand_grid(us_base_sample['gvkey'],
                      us_base_sample['fyear'], ['gvkey', 'fyear'])

    smp = (smp
           .sort_values(["gvkey", "fyear"])
           .merge(us_base_sample, how="left", on=["gvkey", "fyear"])
           .merge(mj, how="left", on=["gvkey", "fyear"])
           .merge(dd, how="left", on=["gvkey", "fyear"])
           .assign(
               ta=lambda x: x['at'],
               avgta=lambda x: (x['at'] + x['at'].shift(1))/2,
               sales=lambda x: x['sale'],
               mktcap=lambda x: x['csho'] * x['prcc_f'],
               ln_ta=lambda x: np.log(x['at']),
               ln_sales=lambda x: np.log(x['sales']),
               ln_mktcap=lambda x: np.log(x['mktcap']),
               mtb=lambda x: (x['csho'] * x['prcc_f'])/x['ceq'],
               sales_growth=lambda x: np.log(
                   x['sale'])/np.log(x['sale'].shift(1)),
               leverage=lambda x: x['lt']/x['at'],
               ppe_ta=lambda x: x['ppent']/x['at'],
               int_ta=lambda x: x['intan']/x['at'],
               gwill_ta=lambda x: x['gdwl']/x['at'],
               acq_sales=lambda x: x['aqs'].add(
                   x['acqsc'], fill_value=0)/x['sale'],
               cogs_sales=lambda x: x['cogs']/x['sale'],
               ebit_sales=lambda x: (x['ib'] + x['xint'])/x['sale'],
               ebit_avgta=lambda x: (x['ib'] + x['xint'])/x['avgta'],
               cfo_avgta=lambda x: x['oancf']/x['avgta'],
               tacc_avgta=lambda x: (x['ibc'] - x['oancf'])/x['avgta'],
               ceq_ta=lambda x: x['ceq']/x['at'],
               mj_ada=lambda x: abs(x['mj_da']),
               dd_ada=lambda x: abs(x['dd_da']))
           .filter(['gvkey', 'conm', 'fyear', 'ff12_ind', 'ff48_ind', 'ta', 'sales', 'mktcap', 'ln_ta', 'ln_sales', 'ln_mktcap', 'mj_da', 'dd_da', 'mj_ada', 'dd_ada', 'mj_nobs', 'dd_nobs', 'mtb', 'sales_growth', 'leverage', 'ppe_ta', 'int_ta', 'gwill_ta', 'ceq_ta', 'acq_sales', 'cogs_sales', 'ebit_sales', 'ebit_avgta', 'cfo_avgta', 'tacc_avgta'])
           .query('mj_da.notna()')
           )

    return smp


def expand_grid(x, y, col_name):
    df = pd.DataFrame(
        list(product(x.unique(), y.unique())), columns=col_name)
    return df


if __name__ == "__main__":
    main()
