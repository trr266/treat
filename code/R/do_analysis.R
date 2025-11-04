# ------------------------------------------------------------------------------
# Prepares figures and tables for our showcase project, exploring discretionary
# accruals.
#
# See LICENSE file for licensing information.
# ------------------------------------------------------------------------------


# --- Read config --------------------------------------------------------------

source("code/R/utils.R")


# --- Read TRR 266 ggplot2 theme -----------------------------------------------

source("code/R/theme_trr.R")


# --- Create tables and figures ------------------------------------------------

log_info("Reading and preparing data...")
smp <- read_parquet(global_cfg$acc_sample)

graph_boxplot <- function(df) {
  df <- df %>%
    select(fyear, mj_da, dd_da) %>%
    filter(!is.na(dd_da)) %>%
    pivot_longer(
      any_of(c("mj_da", "dd_da")), names_to = "type", values_to = "da"
    )

  ggplot(
    df,
    aes(x = fyear, y = da, group = interaction(type, fyear), color = type)
  ) +
    geom_boxplot() +
    labs(
      x = "Fiscal year", y = NULL, color = "Type of discretionary accruals"
    ) +
    scale_color_trr266_d(labels = c("Dechow and Dichev", "Modified Jones")) +
    theme_trr(legend = TRUE)
}

smp_da <- smp %>%
  select(
    gvkey, fyear, ff12_ind, mj_da, dd_da, ln_ta, ln_mktcap, mtb,
    ebit_avgta, sales_growth
  )

smp_da <- smp_da[is.finite(rowSums(smp_da %>% select(-gvkey, -ff12_ind))), ]

smp_da <- treat_outliers(smp_da, by = "fyear")

log_info("Preparing figures...")

fig_boxplot_full <- graph_boxplot(smp)
fig_boxplot_smp <- graph_boxplot(smp_da)

fig_scatter_md_dd <- ggplot(smp_da, aes(x = mj_da, y = dd_da)) +
  geom_bin2d(
    aes(fill = stat(log(count))),  bins = c(100, 100)
  ) +
  labs(x = "Modified Jones DA", y = "Dechow and Dichev DA") +
  scale_fill_trr266_c() +
  theme_trr(axis_y_horizontal = FALSE)

fig_scatter_dd_lnta <- ggplot(smp_da, aes(x = ln_ta, y = dd_da)) +
  geom_bin2d(
    aes(fill = stat(log(count))),  bins = c(100, 100)
  ) +
  labs(x = "ln(Total Assets)", y = "Dechow and Dichev DA") +
  scale_fill_trr266_c() +
  theme_trr(axis_y_horizontal = FALSE)

fig_scatter_dd_roa <- ggplot(smp_da, aes(x = ebit_avgta, y = dd_da)) +
  geom_bin2d(
    aes(fill = stat(log(count))),  bins = c(100, 100)
  ) +
  labs(x = "Return on Assets", y = "Dechow and Dichev DA") +
  scale_fill_trr266_c() +
  theme_trr(axis_y_horizontal = FALSE)

fig_scatter_dd_salesgr <- ggplot(smp_da, aes(x = sales_growth, y = dd_da)) +
  geom_bin2d(
    aes(fill = stat(log(count))),  bins = c(100, 100)
  ) +
  labs(x = "Sales Growth", y = "Dechow and Dichev DA") +
  scale_fill_trr266_c() +
  theme_trr(axis_y_horizontal = FALSE)

log_info("Preparing tables...")

var_names <- tibble(
  var_name = names(smp_da %>% select(-gvkey, -fyear, -ff12_ind)),
  label = cdesc_rnames <- c(
    "Modified Jones DA",
    "Dechow and Dichev DA",
    "Ln(Total assets)",
    "Ln(Market capitalization)",
    "Market to book",
    "Return on assets",
    "Sales growth"
  )
)

N <- function(x) (format(sum(!is.na(x)), big.mark = ","))
desc_smp <- smp_da %>% select(-c(fyear, gvkey, ff12_ind))
colnames(desc_smp) <- var_names$label
tab_desc_stat <- datasummary(
  All(desc_smp) ~ N + Mean + SD + Min + P25 + Median + P75 + Max, 
  data = desc_smp, fmt = 3, output = "gt"
)


rlabels <- paste0(
  LETTERS[1:nrow(var_names)], ": ", colnames(desc_smp)
)
clabels <- c(" ", LETTERS[1:nrow(var_names)])
names(clabels) <- c(" ", rlabels)
colnames(desc_smp) <- rlabels
tab_corr <-datasummary_correlation(
  desc_smp, method = "pearspear", output = "gt"
) %>% cols_label(!!!clabels)

mods <- feols(
  c(mj_da, dd_da) ~ ln_ta + mtb + ebit_avgta + sales_growth | gvkey + fyear,
  smp_da, cluster = c("gvkey", "fyear")
)
for (i in 1:2) {
  mods[[i]]$singletons <- mods[[i]]$nobs_orig - mods[[i]]$nobs
}

names(mods) <- var_names$label[1:2]
ar <- tibble(
  col1 = c(
    "Observations", "Singletons dropped", "Observations used", 
    "Fixed Effects", "SE Clustered"
  ),
  col2 = c(
    format(mods[[1]]$nobs_orig, big.mark = ","),
    format(mods[[1]]$singletons, big.mark = ","),
    format(mods[[1]]$nobs, big.mark = ","),
    "Firm and Year", "Firm and Year"
  ),
  col3 = c(
    format(mods[[2]]$nobs_orig, big.mark = ","),
    format(mods[[2]]$singletons, big.mark = ","),
    format(mods[[2]]$nobs, big.mark = ","),
    "Firm and Year", "Firm and Year"
  )
)
attr(ar, "position") <- 9:13

tab_regression <- modelsummary(
  mods, stars = c(`***` = 0.01, `**` = 0.05, `*` = 0.1),
  estimate = "{estimate}{stars}",
  add_rows = ar,
  gof_map = list(
    list(
      raw = "adj.r.squared", 
      clean = "Adj. R² (overall)", 
      fmt = function(x) sprintf("%.3f", x)
    ),
    list(
      raw = "r2.within.adjusted", clean = "Adj. R² (within)", 
      fmt = function(x) sprintf("%.3f", x)
    )
  ),
  coef_rename = var_names$label[c(3, 5:7)],
  output = "gt"
)

log_info("Done. Storing output objects in '{global_cfg$results_r}'")
save(
  list = c(
    "smp_da", "var_names", ls(pattern = "^fig_*"), ls(pattern = "^tab_*")
  ),
  file = global_cfg$results_r
)
