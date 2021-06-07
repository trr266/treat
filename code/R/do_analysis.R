library(dplyr)
library(tidyr)
library(ggplot2)
library(ExPanDaR)

source("code/R/theme_trr.R")
smp <- readRDS("data/generated/acc_sample.rds")

graph_boxplot <- function(df) {
  df <- df %>% select(fyear, mj_da, dd_da) %>%
    filter(!is.na(dd_da)) %>%
    pivot_longer(any_of(c("mj_da", "dd_da")), names_to = "type", values_to = "da")
  
  ggplot(
    df, 
    aes(x = fyear, y = da, group = interaction(type, fyear), color = type)
  ) +
    geom_boxplot() +
    labs(x = "Fiscal year", y = NULL, color ="Type of discretionary accruals") +
    scale_color_trr266_d(labels = c("Dechow and Dichev", "Modified Jones")) + 
    theme_trr(legend = TRUE)
}

fig_boxplot_full <- graph_boxplot(smp)

smp_da <- smp %>%
  select(
    gvkey, fyear, ff12_ind, mj_da, dd_da, ln_ta, ln_mktcap, mtb,  
    ebit_avgta, sales_growth
  ) 

smp_da <- smp_da[is.finite(rowSums(smp_da %>% select(-gvkey, -ff12_ind))),]

smp_da <- treat_outliers(smp_da, by = "fyear")

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

tab_desc_stat <- prepare_descriptive_table(smp_da %>% select(-fyear))

tab_corr <- prepare_correlation_table(
  smp_da %>% select(-fyear),
  format = "latex", booktabs = TRUE, linesep = ""
)

tab_regression <-  prepare_regression_table(
  smp_da,
  dvs = c("mj_da", "dd_da"),
  idvs = list(
    c("ln_ta", "mtb", "ebit_avgta", "sales_growth"),
    c("ln_ta", "mtb", "ebit_avgta", "sales_growth")
  ),
  feffects = list(c("gvkey", "fyear"), c("gvkey", "fyear")),
  cluster = list(c("gvkey", "fyear"), c("gvkey", "fyear")),
  format = "latex"
)

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

save(
  list = c("smp_da", "var_names", ls(pattern = "^fig_*"), ls(pattern = "^tab_*")),
  file = "output/results.rda"
)
