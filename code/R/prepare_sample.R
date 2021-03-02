# --- Header -------------------------------------------------------------------
# Prepares the "Explore Discretionary Accruals" display 
#
# (C) TRR 266 -  See LICENSE file for details 
# ------------------------------------------------------------------------------
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(purrr)
library(modelr)
library(broom)
library(lubridate)
library(ExPanDaR)

accrual_model_mjones <- function(df) {
  lm(tacc ~ inverse_a + drev + ppe, data = df)
}

accrual_model_dd <- function(df) {
  lm(dwc ~ lagcfo + cfo + leadcfo, data = df)
}

tcoef <- function(m) {as_tibble(t(coef(m)))}

mleadlag <- function(x, n, ts_id) {
  pos <- match(as.numeric(ts_id) + n, as.numeric(ts_id))
  x[pos]
}

winsorize <- function(df, percentile = 0.01, 
                      include=NULL, exclude=NULL, byval=NULL) {
  if (!is.null(exclude) & !is.null(include)) 
    stop("You can only set exclude or include, not both.")
  if (!is.null(exclude)) vars <- !(names(df) %in% exclude)
  else if (!is.null(include)) {
    if (!is.null(byval)) include <- c(byval, include) 
    vars <- names(df) %in% include
  }
  else vars <- names(df)
  ret <- df
  ret[vars] <- treat_outliers(ret[vars], percentile, by = byval)
  return(ret)
}


# --- Prepare base sample ------------------------------------------------------

ff12 <- read_csv(
  "data/external/fama_french_12_industries.csv", col_types = cols()
)
ff48 <- read_csv(
  "data/external/fama_french_48_industries.csv", col_types = cols()
)

rest_data <- readRDS("data/pulled/rest_data.rds")
crsp_ccm_link <- readRDS("data/pulled/crsp_a_ccm_link.rds") %>%
  filter(usedflag == 1,
         linktype %in% c("LU","LC","LD","LN","LS","LX")) %>%
  select(gvkey, lpermno, lpermco, linkdt, linkenddt)

us_base_sample <- readRDS("data/pulled/cstat_us_sample.RDS") %>%
  filter(
    indfmt == "INDL",
    fic == "USA",
    !is.na(at),
    at > 0,
    sale > 0
  ) %>%
  left_join(crsp_ccm_link, by = c("gvkey")) %>%
  mutate(
    crsp = ifelse(
      is.na(lpermno), FALSE,
      ifelse(
        is.na(linkenddt), 
        datadate >= linkdt,  
        datadate >= linkdt &
          linkenddt >= datadate %m-% months(12))
      )
    ) %>%
  # this generates duplicates for firms with multiple shares outstanding
  # or for firms that change the issue during the fiscal year. We do
  # not care about the exact share link as we won't be linking CRSP
  # data. We simply keep the first match
  distinct(gvkey, fyear, .keep_all = TRUE) %>%
  select(-lpermno, -lpermco, -linkdt, -linkenddt) %>%
  mutate(sic = ifelse(!is.na(sich), sprintf("%04d", sich), sic)) %>%
  filter(
    !is.na(sic),
    as.numeric(sic) < 6000 | as.numeric(sic) > 6999
  ) %>%
  left_join(ff48, by = "sic") %>%
  left_join(ff12, by = "sic") %>%
  filter(!is.na(ff48_ind) & !is.na(ff12_ind)) 

rd <- us_base_sample %>%
  select(gvkey, fyear, cik, datadate) %>%
  rename(fye = datadate) %>%
  mutate(fys = fye - years(1)) %>%
  full_join(rest_data, by = c("cik" = "company_fkey")) %>%
  filter(
    !is.na(res_notif_key),
    !(fys >  res_end_date),
    !(fye < res_begin_date)
  ) %>%
  group_by(gvkey, fyear) %>% 
  summarise(
    res_accounting = sum(res_accounting) > 0,
    res_fraud = sum(res_fraud) > 0,
    res_sec_invest = sum(res_sec_invest) > 0,
    res_adverse = sum(res_adverse) > sum(res_improves),
    .groups = "drop"
  ) %>%
  filter(res_accounting | res_fraud | res_sec_invest) 


# --- Calculate modified Jones model accruals and statistics -------------------


estimate_mj_accruals <- function(df, min_obs = 10) {
  # Methodology is somewhat loosely based on Hribar and Nichols (JAR, 2007)
  # https://doi.org/10.1111/j.1475-679X.2007.00259.x
  mj <- df %>%
    group_by(gvkey) %>%
    mutate(
      lagta = mleadlag(at, -1, fyear),
      tacc = (ibc - oancf)/lagta,
      drev = (sale - mleadlag(sale, -1, fyear) + recch)/lagta,
      inverse_a = 1/lagta,
      ppe = ppegt/lagta
    ) %>%
    filter(
      !is.na(tacc),
      !is.na(drev),
      !is.na(ppe)
    ) %>%
    group_by(ff48_ind, fyear) %>%
    filter(n() >= min_obs) %>%
    winsorize(include = c("tacc", "drev", "inverse_a", "ppe")) %>%
    nest() %>%
    mutate(model = map(data, accrual_model_mjones)) 
  
  mj_resids <- mj %>%
    mutate(residuals = map2(data, model, add_residuals)) %>%
    unnest(residuals) %>%
    rename(mj_da = resid) %>%
    select(gvkey, fyear, ff48_ind, mj_da)
  
  mj_adjr2s <- mj %>%
    mutate(glance = map(model, glance)) %>%
    unnest(glance) %>%
    rename(mj_adjr2 = adj.r.squared) %>%
    select(ff48_ind, fyear, mj_adjr2)
  
  mj_coefs <- mj %>%
    mutate(coef = map(model, tcoef)) %>%
    select(ff48_ind, fyear, coef) %>%
    unnest(coef) %>%
    rename(mj_intercept = "(Intercept)",
           mj_inverse_a = inverse_a,
           mj_drev = drev,
           mj_ppe = ppe)
  
  mj_resids %>%
    left_join(mj_adjr2s, by = c("ff48_ind", "fyear")) %>%
    left_join(mj_coefs, by = c("ff48_ind", "fyear"))
}



# --- Calculate Dechow/Dichev accruals and statistics --------------------------

# Methodology is based on Dechow and Dichev (TAR, 2002)
# https://doi.org/10.2308/accr.2002.77.s-1.35

estimate_dd_accruals <- function(df, min_obs = 10) {
  dd <- df %>%
    group_by(gvkey) %>%
    mutate(avgta = (at + mleadlag(at, -1, fyear))/2,
           cfo = oancf/avgta,
           lagcfo = mleadlag(cfo, -1, fyear),
           leadcfo = mleadlag(cfo, +1, fyear),
           dwc = -(recch + invch + apalch + txach + aoloch)/avgta) %>%
    filter(!is.na(dwc),
           !is.na(cfo),
           !is.na(lagcfo),
           !is.na(leadcfo)) %>%
    group_by(ff48_ind, fyear) %>%
    filter(n() >= min_obs) %>%
    winsorize(include = c("dwc", "cfo", "lagcfo", "leadcfo")) %>%
    nest() %>%
    mutate(model = map(data, accrual_model_dd)) 
  
  dd_resids <- dd %>%
    mutate(residuals = map2(data, model, add_residuals)) %>%
    unnest(residuals) %>%
    rename(dd_da = resid) %>%
    select(gvkey, ff48_ind, fyear, dd_da)
  
  dd_adjr2s <- dd %>%
    mutate(glance = map(model, glance)) %>%
    unnest(glance) %>%
    rename(dd_adjr2 = adj.r.squared) %>%
    select(ff48_ind, fyear, dd_adjr2)
  
  dd_coefs <- dd %>%
    mutate(coef = map(model, tcoef)) %>%
    select(ff48_ind, fyear, coef) %>%
    unnest(coef) %>%
    rename(dd_intercept = "(Intercept)",
           dd_lagcfo = lagcfo,
           dd_cfo = cfo,
           dd_leadcfo = leadcfo)

  dd_resids %>%
    left_join(dd_adjr2s, by = c("ff48_ind", "fyear")) %>%
    left_join(dd_coefs, by = c("ff48_ind", "fyear"))
}


# --- Merge data and prepare samples -------------------------------------------

mj <- estimate_mj_accruals(us_base_sample) 
dd <- estimate_dd_accruals(us_base_sample) 

smp<- expand_grid(
  gvkey = unique(us_base_sample$gvkey),
  fyear = unique(us_base_sample$fyear)
) %>%
  arrange(gvkey, fyear) %>%
  left_join(us_base_sample, by = c("gvkey", "fyear")) %>%
  left_join(mj, by = c("gvkey", "fyear")) %>%
  left_join(dd, by = c("gvkey", "fyear")) %>%
  left_join(rd, by = c("gvkey", "fyear")) %>%
  mutate(
    ta = at,
    avgta = (at + lag(at))/2,
    sales = sale,
    mktcap = csho * prcc_f,
    ln_ta = log(at),
    ln_sales = log(sales),
    ln_mktcap = log(mktcap),
    mtb = (csho * prcc_f)/ceq,
    sales_growth = sale/lag(sale),
    leverage = lt/at,
    ppe_ta = ppent/at,
    int_ta = intan/at,
    gwill_ta = gdwl/at,
    acq_sales = (ifelse(!is.na(aqs), aqs, 0) + 
                        ifelse(!is.na(acqsc), acqsc, 0))/sale,
    cogs_sales = cogs/sale,
    ebit_sales = (ib + xint)/sale,
    ebit_avgta = (ib + xint)/avgta,
    cfo_avgta = oancf/avgta,
    tacc_avgta = (ibc - oancf)/avgta,
    ceq_ta = ceq/at,
    mj_ada = abs(mj_da),
    dd_ada = abs(dd_da),
    res_accounting = ifelse(is.na(res_accounting), FALSE, res_accounting), 
    res_fraud = ifelse(is.na(res_fraud), FALSE, res_fraud), 
    res_sec_invest = ifelse(is.na(res_sec_invest), FALSE, res_sec_invest), 
    res_adverse = ifelse(is.na(res_adverse), FALSE, res_adverse), 
    restatement = res_accounting | res_fraud | res_sec_invest) %>%
  select(
    gvkey, conm, fyear, ff12_ind, ff48_ind,
    ta, sales, mktcap, ln_ta, ln_sales, ln_mktcap,
    mj_da, dd_da, mj_ada, dd_ada,
    mtb, sales_growth, leverage,
    ppe_ta, int_ta, gwill_ta, ceq_ta, leverage, 
    acq_sales, cogs_sales, ebit_sales, 
    ebit_avgta, cfo_avgta, tacc_avgta,
    restatement, res_accounting, res_fraud, res_sec_invest, res_adverse) %>%
  filter(!is.na(mj_da),
         fyear > 1993,
         fyear < 2020)

saveRDS(smp, "data/generated/acc_sample.rds")
