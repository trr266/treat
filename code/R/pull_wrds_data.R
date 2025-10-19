# ------------------------------------------------------------------------------
# Downloads WRDS data to local parquet files using a duckdb workflow
#
# See LICENSE file for licensing information.
# ------------------------------------------------------------------------------

# Good starting points to learn more about this workflow are
# - The support pages of WRDS (they also contain the data documentation)
# - The wonderful textbook by Ian Gow (https://iangow.github.io/far_book/),
#   in particular App. D and E

source("code/R/utils.R")
cfg <- read_config("config/pull_wrds_data_cfg.yaml")

# Downloading data from WRDS is resource intensive. So, by default,
# this code only downloads data if it is not available locally.
# You can set the `force_redownload` config variable to bypass this behavior

# Also the config file specifies which tables to download, the variables
# to keep and filters to apply. You can modify these as needed.

# The secrets file should contain your WRDS login data
secrets <- read_secrets()


# --- Some helper functions to connect to duckdb and WRDS ----------------------

connect_duckdb <- function(dbase_path = ":memory:") {
  dbConnect(
    duckdb::duckdb(), dbase_path
  )
}

shutdown_duckdb <- function(con) {
  dbDisconnect(con, shutdown = TRUE)
}

link_wrds_to_duckdb <- function(con) {
  rv <- dbExecute(
    con, sprintf(paste(
      "INSTALL postgres;",
      "LOAD postgres;",
      "SET pg_connection_limit=4;",
      "ATTACH '",
      "dbname=wrds host=wrds-pgdata.wharton.upenn.edu port=9737",
      "user=%s password=%s' AS wrds (TYPE postgres, READ_ONLY)"
    ), secrets$wrds_user, secrets$wrds_pwd)
  )
}

list_wrds_libs_and_tables <- function(con) {
  dbGetQuery(
    con, "SHOW ALL TABLES"
  )
}

query_wrds_to_parquet <- function(con, query, parquet_file, force = FALSE) {
  time_in <- Sys.time()
  if (file.exists(parquet_file) & ! force) {
    log_info(
      "Parquet file '{parquet_file}' exists. ",
      "Skipping it but updating its mtime. ",
      "Delete it if you want to re-download"
    )
    Sys.setFileTime(parquet_file, Sys.time())
    return(invisible())
  }
  rv <- dbExecute(
    con, glue_sql(
      "COPY ({query}) TO {parquet_file} (FORMAT 'parquet')",
      .con = con
    )
  )
  time_spent <- round(Sys.time() - time_in)
  log_info(
    "Query result saved to '{parquet_file}': ",
    "rows: {format(rv, big.mark = ',')}, ",
    "time spent: {as_hms(time_spent)}"
  )
}


# --- Downloading U.S. Compustat data ------------------------------------------

con <- connect_duckdb()
link_wrds_to_duckdb(con)
log_info("Linked WRDS to local Duck DB instance.")


dyn_vars <- cfg$dyn_vars
stat_vars <- cfg$stat_vars
cs_filter <- cfg$cs_filter

log_info("Pulling Compustat data")
query <- glue_sql(
  "select s.*, d.* from ",
  "(select {`stat_vars`*} from wrds.comp.company) s ",
  "join (select {`dyn_vars`*} from wrds.comp.funda ",
  paste0("where ", cs_filter, ") d "),
  "on (s.gvkey = d.gvkey)", .con = con, .literal = TRUE
)

query <- glue_sql(
  "select * from ",
  "(select {`stat_vars`*} from wrds.comp.company) ",
  "join (select {`dyn_vars`*} from wrds.comp.funda ",
  paste0("where ", cs_filter, ") "),
  "using (gvkey)", .con = con
)

query_wrds_to_parquet(
  con, query, global_cfg$cstat_us_parquet_file,
  force = cfg$force_redownload
)

shutdown_duckdb(con)
log_info("Disconnected from WRDS")
