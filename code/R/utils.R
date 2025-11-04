# ------------------------------------------------------------------------------
# Code that should be included in all R scripts. Reads global config,
# sets up logging, and provides utility functions.
#
# See LICENSE file for licensing information.
# ------------------------------------------------------------------------------


# --- Attach required R packages -----------------------------------------------

# This attaches all packages that are required by any parts of the code. While
# this technically is not required for each and any code file and might also
# cause issues by conflicting namespaces, we follow this approach so that we
# single consistent R session throughout our code base.

suppressWarnings(suppressPackageStartupMessages({
  library(logger)
  library(glue)
  library(dotenv)
  library(yaml)
	library(readr)
	library(dplyr)
	library(tidyr)
	library(ggplot2)
	library(purrr)
	library(modelr)
	library(broom)
	library(lubridate)
	library(hms)
	library(duckdb)
	library(arrow)
	library(modelsummary)
	library(fixest)
	library(gt)
}))


# --- Reading configuration files ----------------------------------------------

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


# --- Setting up logging -------------------------------------------------------

if (!is.na(global_cfg$log_level) && global_cfg$log_level != "") {
  log_threshold(toupper(global_cfg$log_level))
}

if (
  !is.na(global_cfg$log_file) && global_cfg$log_file != "" &&
    tolower(global_cfg$log_file) != "stdout"
) {
  log_appender(appender_file(global_cfg$log_file))
}


# --- Utility functions --------------------------------------------------------

# --- Lend from ExPanDaR package
treat_outliers <- function(
  x, percentile = 0.01, truncate = FALSE, by = NULL, ...
) {
  treat_vector_outliers <- function(x, truncate, percentile, ...) {
    lim <- quantile(
      x, probs = c(percentile, 1 - percentile), na.rm = TRUE, ...
    )
    if (!truncate) {
      x[x < lim[1]] <- lim[1]
      x[x > lim[2]] <- lim[2]
    } else {
      x[x < lim[1]] <- NA
      x[x > lim[2]] <- NA
    }
    x
  }

  if (!is.data.frame(x)) stop("'x' needs to be a data frame.")
  lenx <- nrow(x)
  if (!is.numeric(percentile) || (length(percentile) != 1)) 
    stop("bad value for 'percentile': Needs to be a numeric scalar")
  if (percentile <= 0 | percentile >= 0.5) {
    stop("bad value for 'percentile': Needs to be > 0 and < 0.5")
  }
  if (length(truncate) != 1 || !is.logical(truncate)) 
    stop("bad value for 'truncate': Needs to be a logical scalar")
  if (!is.null(by)) {
    by <- as.vector(x[[by]])
    if (anyNA(by)) 
      stop("by vector contains NA values")
    if (length(by) != lenx) 
      stop("by vector number of rows differs from x")
  }
  df <- x
  x <- x[sapply(x, is.numeric)]
  if (!is.numeric(as.matrix(x))) 
    stop("bad value for 'x': needs to contain numeric vector or matrix")
  x <- do.call(
    data.frame, lapply(x, function(xv) replace(xv, !is.finite(xv), NA))
  )
  if (is.null(by)) {
    retx <- as.data.frame(
      lapply(
        x, function(vx) treat_vector_outliers(
          vx, truncate, percentile, ...
        )
      )
    )
  } else {
    old_order <- (1:lenx)[order(by)]
    retx <- do.call(
      rbind, 
      by(
        x, by, 
        function(mx) apply(mx, 2, function(vx) treat_vector_outliers(
          vx, truncate, percentile, ...
        ))
      )
    )
    retx <- as.data.frame(retx[order(old_order), ])
  }
  df[colnames(retx)] <- retx
  return(df)
}

