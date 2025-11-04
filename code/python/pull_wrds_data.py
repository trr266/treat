# ------------------------------------------------------------------------------
# Downloads WRDS data to local parquet files using a duckdb workflow
#
# See LICENSE file for licensing information.
# ------------------------------------------------------------------------------

# Good starting points to learn more about this workflow are
# - The support pages of WRDS (they also contain the data documentation)
# - The wonderful textbook by Ian Gow (https://iangow.github.io/far_book/),
#   in particular App. D and E

import os
from pathlib import Path
from datetime import datetime
import duckdb
from dotenv import load_dotenv

from utils import read_config, setup_logging

log = setup_logging()
global_cfg = read_config('config/global_cfg.yaml')


def main():
    """
    Main function to pull data from WRDS using DuckDB.
    
    This function reads the configuration file, connects to WRDS via DuckDB's
    PostgreSQL extension, and pulls the data from WRDS by executing a SQL query
    that joins tables server-side before downloading. This is much more efficient
    than downloading separate tables and merging locally.
    """
    cfg = read_config('config/pull_wrds_data_cfg.yaml')
    secrets = read_secrets()
    
    con = connect_duckdb()
    link_wrds_to_duckdb(con, secrets)
    log.info("Linked WRDS to local DuckDB instance.")
    
    log.info("Pulling Compustat data")
    query = build_compustat_query(cfg, con)
    
    query_wrds_to_parquet(
        con, 
        query, 
        global_cfg['cstat_us_parquet_file'],
        force=cfg['force_redownload']
    )
    
    shutdown_duckdb(con)
    log.info("Disconnected from WRDS")


def read_secrets():
    """
    Reads WRDS credentials from secrets file.
    
    Returns:
        dict: Dictionary with 'wrds_user' and 'wrds_pwd' keys
    """
    secrets_file = global_cfg['secrets_file']
    if not os.path.exists(secrets_file):
        raise FileNotFoundError(
            f"Secrets file '{secrets_file}' not found. "
            "Please create it with WRDS_USERNAME and WRDS_PASSWORD."
        )
    
    load_dotenv(secrets_file)
    wrds_user = os.getenv('WRDS_USERNAME')
    wrds_pwd = os.getenv('WRDS_PASSWORD')
    
    if not wrds_user or not wrds_pwd:
        raise ValueError(
            "WRDS_USERNAME and WRDS_PASSWORD must be set in secrets file"
        )
    
    return {'wrds_user': wrds_user, 'wrds_pwd': wrds_pwd}


def connect_duckdb(dbase_path=":memory:"):
    """
    Creates a DuckDB connection.
    
    Args:
        dbase_path: Path to database file, or ":memory:" for in-memory database
        
    Returns:
        duckdb.DuckDBPyConnection: Database connection
    """
    return duckdb.connect(dbase_path)


def shutdown_duckdb(con):
    """
    Properly shuts down DuckDB connection.
    
    Args:
        con: DuckDB connection to close
    """
    con.close()


def link_wrds_to_duckdb(con, secrets):
    """
    Attaches WRDS PostgreSQL database to DuckDB.
    
    This allows querying WRDS tables directly through DuckDB using the 'wrds' schema.
    
    Args:
        con: DuckDB connection
        secrets: Dictionary with 'wrds_user' and 'wrds_pwd' keys
    """
    attach_query = f"""
        INSTALL postgres;
        LOAD postgres;
        SET pg_connection_limit=4;
        ATTACH 'dbname=wrds host=wrds-pgdata.wharton.upenn.edu port=9737 
                user={secrets['wrds_user']} password={secrets['wrds_pwd']}' 
        AS wrds (TYPE postgres, READ_ONLY);
    """
    con.execute(attach_query)


def build_compustat_query(cfg, con):
    """
    Builds the SQL query to pull Compustat data from WRDS.
    
    The query joins the static company table with the dynamic funda table
    on the server side before downloading, which is much more efficient.
    
    Uses USING (gvkey) to automatically handle the join key and avoid duplication.
    
    Args:
        cfg: Configuration dictionary
        con: DuckDB connection
        
    Returns:
        str: SQL query string
    """
    dyn_vars = cfg['dyn_vars']
    stat_vars = cfg['stat_vars']
    cs_filter = cfg['cs_filter']
    
    dyn_vars_quoted = [f'"{var}"' for var in dyn_vars]
    stat_vars_quoted = [f'"{var}"' for var in stat_vars]
    
    dyn_vars_str = ', '.join(dyn_vars_quoted)
    stat_vars_str = ', '.join(stat_vars_quoted)
    
    query = (
        f"SELECT * FROM "
        f"(SELECT {stat_vars_str} FROM wrds.comp.company) "
        f"JOIN (SELECT {dyn_vars_str} FROM wrds.comp.funda WHERE {cs_filter}) "
        f'USING ("gvkey")'
    )
    
    return query


def query_wrds_to_parquet(con, query, parquet_file, force=False):
    """
    Executes a query on WRDS and saves the result to a parquet file.
    
    Args:
        con: DuckDB connection with WRDS attached
        query: SQL query string
        parquet_file: Path to output parquet file
        force: If True, re-download even if file exists
    """
    time_in = datetime.now()
    
    if os.path.exists(parquet_file) and not force:
        log.info(
            f"Parquet file '{parquet_file}' exists. "
            "Skipping it but updating its mtime. "
            "Delete it if you want to re-download"
        )
        Path(parquet_file).touch()
        return
    
    query_clean = ' '.join(query.split())
    
    copy_query = f"COPY ({query_clean}) TO '{parquet_file}' (FORMAT 'parquet')"
    result = con.execute(copy_query)
    row_count = result.fetchone()[0] if result else 0
    
    time_spent = datetime.now() - time_in
    log.info(
        f"Query result saved to '{parquet_file}': "
        f"rows: {row_count:,}, "
        f"time spent: {time_spent}"
    )


if __name__ == '__main__':
    main()
