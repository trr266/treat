# ------------------------------------------------------------------------------
# This reads the config file in project root and stores all variables in a list
# named cfg.
#
# (c) TRR 266 - Read LICENSE for details
# ------------------------------------------------------------------------------

if (!file.exists("config.csv")) stop(paste(
  "File 'config.csv' not found in project root. Please edit",
  "'_config.csv' and safe it as 'config.csv'."
))

df <- readr::read_csv("config.csv", col_type = readr::cols(), comment = "#")

cfg <- as.list(df$value)
names(cfg) <- df$variable