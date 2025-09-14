# ------------------------------------------------------------------------------
# Code that should be included in all R scripts. Reads global config,
# sets up logging, nd provides utility functions.
#
# See LICENSE file for licensing
# ------------------------------------------------------------------------------

suppressWarnings(suppressPackageStartupMessages({
  library(logger)
  library(glue)
  library(dotenv)
  library(yaml)
}))


# Reading configuration files

read_config <- function(config_file) {
  read_yaml(config_file)
}

global_cfg <- read_config("config/global_cfg.yaml")

read_secrets <- function() {
  if (!file.exists(global_cfg$secrets_file)) {
    log_error("Secrets file '{global_cfg$secrets_file}' not found. Exiting.")
    stop(paste(
      "Please copy '_{global_cfg$secrets_file}' to '{global_cfg$secrets_file}'",
      "and edit it to contain your WRDS access data prior to running this code"
    ))
  }

  load_dot_env("secrets.env")
  list(
    wrds_user = Sys.getenv("WRDS_USERNAME"),
    wrds_pwd = Sys.getenv("WRDS_PASSWORD")
  )
}


# Setting up logging

if (!is.na(global_cfg$log_level) && global_cfg$log_level != "") {
  log_threshold(toupper(global_cfg$log_level))
}

if (
  !is.na(global_cfg$log_file) && global_cfg$log_file != "" &&
    tolower(global_cfg$log_file) != "stdout"
) {
  log_appender(appender_file(global_cfg$log_file))
}
