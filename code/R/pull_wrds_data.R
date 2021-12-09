# --- Header -------------------------------------------------------------------
# See LICENSE file for details 
#
# This code pulls data from WRDS 
# ------------------------------------------------------------------------------
#
library(RPostgres)
library(DBI)
#
save_rds_versionctrl <- function(df, fname) {
  if(file.exists(fname)) {
    file.rename(
      fname,
      paste0(
        substr(fname, 1, nchar(fname) - 4), 
        "_",
        format(file.info(fname)$mtime, "%Y-%m-%d_%H_%M_%S"),".rds")
    )
  }
  saveRDS(df, fname)
}
#
# --- Connection to WRDS -------------------------------------------------------
source("code/R/connect_WRDS.R")
#
#
# --- Specify filters and variables --------------------------------------------
#
dyn_vars <- c(
  "gvkey", "conm", "cik", "fyear", "datadate", "indfmt", "sich",
  "consol", "popsrc", "datafmt", "curcd", "curuscn", "fyr", 
  "act", "ap", "aqc", "aqs", "acqsc", "at", "ceq", "che", "cogs", 
  "csho", "dlc", "dp", "dpc", "dt", "dvpd", "exchg", "gdwl", "ib", 
  "ibc", "intan", "invt", "lct", "lt", "ni", "capx", "oancf", 
  "ivncf", "fincf", "oiadp", "pi", "ppent", "ppegt", "rectr", 
  "sale", "seq", "txt", "xint", "xsga", "costat", "mkvalt", "prcc_f",
  "recch", "invch", "apalch", "txach", "aoloch",
  "gdwlip", "spi", "wdp", "rcp"
)
#
dyn_var_str <- paste(dyn_vars, collapse = ", ")
#
stat_vars <- c("gvkey", "loc", "sic", "spcindcd", "ipodate", "fic")
stat_var_str <- paste(stat_vars, collapse = ", ")
#
cs_filter <- "consol='C' and (indfmt='INDL' or indfmt='FS') and datafmt='STD' and popsrc='D'"
#
#
# --- Pull Compustat data ------------------------------------------------------
#
message("Pulling dynamic Compustat data ... ", appendLF = FALSE)
res <- dbSendQuery(wrds, paste(
  "select", 
  dyn_var_str, 
  "from COMP.FUNDA",
  "where", cs_filter
))
#
wrds_us_dynamic <- dbFetch(res, n=-1)
dbClearResult(res)
message("done!")

message("Pulling static Compustat data ... ", appendLF = FALSE)
res2<-dbSendQuery(wrds, paste(
  "select ", stat_var_str, "from COMP.COMPANY"
))
#
wrds_us_static <- dbFetch(res2,n=-1)
dbClearResult(res2)
message("done!")
#
wrds_us <- merge(wrds_us_static, wrds_us_dynamic, by="gvkey")
save_rds_versionctrl(wrds_us, "data/pulled/cstat_us_sample.rds")
#
dbDisconnect(wrds)
rm(wrds)
message("Disconnected from WRDS")
#
