# --- Header -------------------------------------------------------------------
# See LICENSE file for details 
#
# This code establishes a connection to WRDS
# ------------------------------------------------------------------------------
#
#
library(RPostgres)
library(DBI)
#
#
message("Trying to establish connection to WRDS")
#
#
# --- WRDS Credentials ----------------------------------------------------------
if(file.exists("config.csv")){
  df <- readr::read_csv("config.csv", col_type = readr::cols(), comment = "#")
  cfg <- as.list(df$value)
  names(cfg) <- df$variable
  rm(df) 
  wrds_user <- cfg$wrds_user
  wrds_pwd <- cfg$wrds_pwd
  rm(cfg)
} else if(rstudioapi::isAvailable()) {
    wrds_user <- rstudioapi::askForPassword(prompt="Enter your WRDS username")
    wrds_pwd   <- rstudioapi::askForPassword()
} else if(!rstudioapi::isAvailable()) {
      stop("
          cannot establish connection to WRDS (connect_WRDS.R) 
          - missing WRDS credentials (wrds_user & wrds_pwd)
          - see _config.csv for troubleshooting")
} 
#
#
# --- WRDS Connection ----------------------------------------------------------
wrds <- dbConnect(
  Postgres(),
  host = 'wrds-pgdata.wharton.upenn.edu',
  port = 9737,
  user = wrds_user,
  password = wrds_pwd,
  sslmode = 'require',
  dbname = 'wrds'
)
rm(wrds_user)
rm(wrds_pwd)
message("Logged on to WRDS!")
#
#
