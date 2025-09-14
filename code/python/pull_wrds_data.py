# --- Header -------------------------------------------------------------------
# See LICENSE file for details
#
# This code pulls data from WRDS
# ------------------------------------------------------------------------------
import os
from getpass import getpass
import dotenv

import pandas as pd
from utils import read_config, setup_logging
import wrds

log = setup_logging()
global_cfg = read_config('config/global_cfg.yaml')

def main():
    '''
    Main function to pull data from WRDS.

    This function reads the configuration file, gets the WRDS login credentials, and pulls the data from WRDS.

    The data is then saved to a csv file.
    '''
    cfg = read_config('config/pull_wrds_data_cfg.yaml')
    wrds_login = get_wrds_login()
    wrds_us = pull_wrds_data(cfg, wrds_login)
    wrds_us.to_parquet(global_cfg['cstat_us_parquet_file'], index=False)

    
def get_wrds_login():
    '''
    Gets the WRDS login credentials.
    '''
    if os.path.exists(global_cfg['secrets_file']):
        dotenv.load_dotenv(global_cfg['secrets_file'])
        wrds_username = os.getenv('WRDS_USERNAME')
        wrds_password = os.getenv('WRDS_PASSWORD')
        return {'wrds_username': wrds_username, 'wrds_password': wrds_password}
    else:
        wrds_username = input('Please provide a wrds username: ')
        wrds_password = getpass(
            'Please provide a wrds password (it will not show as you type): ')
        return {'wrds_username': wrds_username, 'wrds_password': wrds_password}
    
def pull_wrds_data(cfg, wrds_authentication):
    '''
    Pulls WRDS access data.
    '''
    db = wrds.Connection(
        wrds_username=wrds_authentication['wrds_username'], 
        wrds_password=wrds_authentication['wrds_password']
    )

    log.info('Logged on to WRDS ...')

    dyn_var_str = ', '.join(cfg['dyn_vars'])
    stat_var_str = ', '.join(cfg['stat_vars'])

    log.info("Pulling dynamic Compustat data ... ")
    wrds_us_dynamic = db.raw_sql(
        f"SELECT {dyn_var_str} FROM comp.funda WHERE {cfg['cs_filter']}"
    )
    log.info("Pulling dynamic Compustat data ... Done!")

    log.info("Pulling static Compustat data ... ")
    wrds_us_static = db.raw_sql(f'SELECT {stat_var_str} FROM comp.company')
    log.info("Pulling static Compustat data ... Done!")

    db.close()
    log.info("Disconnected from WRDS")

    wrds_us = pd.merge(wrds_us_static, wrds_us_dynamic, "inner", on="gvkey")

    return wrds_us


if __name__ == '__main__':
    main()
