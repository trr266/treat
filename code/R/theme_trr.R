# ------------------------------------------------------------------------------
# Some utility functions and our TRR 266 ggplot2 Theme
#
# (c) TRR 266 - Read LICENSE for details
# ------------------------------------------------------------------------------

theme_trr <- function(
  plot_type = "default", legend = FALSE, text_size = 11,
  axis_y_horizontal = TRUE
) {
  plot_type <- if (!is.null(plot_type)) tolower(plot_type)

  if (!plot_type %in% c(
    "bar", "box", "lollipop", "line", "scatter", "smoother", "default"
  )) {
    stop(paste(
      "theme_trr: plot_type has to be 'defaut', 'bar', 'box', 'lollipop'", 
      "'line', 'scatter' or 'smoother'."
    ))
  }

  base_theme <- function() {
    theme_grey() +
      theme(
        text = element_text(size = text_size),
        axis.title.y = if (axis_y_horizontal) {
          element_text(angle = 0)
        } else {
          element_text(angle = 90)
        },
        axis.ticks = element_blank(),
        axis.line = if (plot_type %in% c("line", "scatter", "default")) {
          element_blank()
        } else {
          element_line(size = 0.3, lineend = "round")
        },
        legend.position = if (legend) "top" else "none",
        legend.background = element_blank(),
        legend.margin = margin(1, 1, 1, 1),
        legend.key = element_blank(),
        legend.direction = "horizontal",
        legend.box.background = element_blank(),
        panel.background = element_blank(),
        panel.grid = element_line(colour = "#EBEBEBFF", size = 0.4),
        panel.grid.minor.x = if (!plot_type %in% c("lollipop", "scatter")) {
          element_blank()
        } else {
          NULL
        },
        panel.grid.major.x = if (!plot_type %in% c("lollipop", "scatter")) {
          element_blank()
        } else {
          NULL
        },
        panel.grid.major.y = if (plot_type %in% c("lollipop")) {
          element_blank()
        } else {
          NULL
        },
        panel.grid.minor.y =
          if (plot_type %in% c("lollipop", "scatter", "smoother")) {
            element_blank()
          } else {
            NULL
          },
        plot.background = element_blank(),
        plot.title = element_text(face = "bold")
      )
  }
  base_theme()
}

col_trr266_petrol <- "#1B8A8F"
col_trr266_yellow <- "#FFB43B"
col_trr266_blue <- "#6ECAE2"
col_trr266_red <- "#944664"
col_trr266_nightblue <- "#22355D"
col_trr266_iceblue <- "#1D758D"
col_trr266_darkgreen <- "#224B4F"

trr266_colors <- c(
  col_trr266_petrol, col_trr266_yellow, col_trr266_blue,
  col_trr266_red, col_trr266_nightblue, col_trr266_iceblue,
  col_trr266_darkgreen
)

trr266_palette <- function() palette(trr266_colors)

show_trr_colors <- function() {
  scales::show_col(trr266_colors, ncol = 4, borders = NA)
}

scale_fill_trr266_d <- function(...) {
  scale_fill_manual(values = c(
    "#1B8A8FFF", "#FFB43BFF", "#6ECAE2FF", "#944664FF",
    "#22355DFF", "#1D758DFF", "#224B4FFF"
  ), ...)
}

scale_fill_trr266_c <- function(base_color = col_trr266_petrol, ...) {
  scale_fill_gradient(
    high = base_color, 
    low = colorspace::lighten(base_color, 0.9), ...
  )
}

scale_color_trr266_d <- function(...) {
  scale_colour_manual(values = c(
    "#1B8A8FFF", "#FFB43BFF", "#6ECAE2FF", "#944664FF",
    "#22355DFF", "#1D758DFF", "#224B4FFF"
  ), ...)
}

scale_color_trr266_c <- function(base_color = col_trr266_petrol, ...) {
  scale_color_gradient(
    high = base_color, 
    low = colorspace::lighten(base_color, 0.9), ...
  )
}
