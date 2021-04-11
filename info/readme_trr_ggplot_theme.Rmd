---
title: "Meet theme_trr.R"
author: "The C02 team"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(
  echo = TRUE, warning = FALSE, message = FALSE
)
```


## Helpers for creating TRR 266-themed graphics in R

This is the documentation for a small set of helper objects functions that make it easier for you to create TRR 266-themed graphics in R. They include a dedicated ggplot theme `theme_trr()`. Everything is included in the code file `theme_trr.R`. 

You can use the `theme_trr` objects as follows:

```{r warning=FALSE, message=FALSE}
library(tidyverse)

# The below sources the theme directly from the repository

devtools::source_url("https://raw.githubusercontent.com/trr266/treat/main/code/R/theme_trr.R")

# Alternatively, you can copy the theme file to your local working
# directory and source it locally 
# source("theme_trr.R")
```


## Overview of selected TRR 266 style guidelines for graphs

The TRR 266 'Accounting for Transparency' style guidelines define various aspects for the design of TRR 266 publications. Here we focus on colors and typography. Note that the following recommendations are our opinions and might be not be applicable or should be customized for your plots. 

Our TRR 266 colors differentiate into primary and secondary colors. Primary colors of the TRR266 are petrol ("#1b8a8f") as the main color as well as yellow ("#ffb43b"), blue ("#6ecae2"), and red ("#944664"). Secondary colors are variants of blue ("#22355d", "#1d758d", "#224b4f"). It is recommended to use the primary colors. If you want to add color variation, you can adjust the saturation of the color.

You can get a quick glance of the colors by running

```{r}
show_trr_colors()
```

These colors are also available by using the palette function `trr266_palette()` and as variables starting with `col_trr266` for convenience. So you can do:

```{r}
x <- rnorm(1000)
hist(x, col = col_trr266_red)
```
The typography described in the TRR266 style guidelines focus on two fonts: Cambria and Calibri Light. To emphasize text one can use bold print, color variations or a combination thereof.

You can access the current TRR266 style guidelines on Nextcloud here: [Link to TRR266 style guide](https://trr266.wiwi.hu-berlin.de/cloud/apps/files/?dir=/trr266_all/trr266_c03&fileid=25706#pdfviewer).

There is a blogpost article by Astrid van Kimmenrade and Joachim Gassen that discusses Do's and Dont's of data visualization. We include the main points style guidelines for graphing are as follows:

- **Remove chart junk**: always get rid of unnecessary clutter, clean up your charts. A few simple tweaks make graphs easier on the eyes. Make the axes less prominent (grey and thinner lines), remove unnecessary lines, and make the numbers on the axes grey and smaller.
- **Check your axes**: it is preferable to use “natural” increments, meaning 2-4-6-8 is preferred over 3-6-9, and 0-50-100% over 30-60-90%.
- **Add context**: you can add text describing the data as an introduction to the visual. This way the visual can be a stand-alone, and if it is copied or shared by others, the context is not lost (as long as the image is not cropped ;-))
- **Annotate**: this is something we rarely see in scientific publications, but annotating a graph is a very user-friendly approach. Especially in the case, where one offers an explanatory visual (vs. exploratory visual). Small annotations that compare plotted lines or bars help to tell a story. Of course, annotations should be used sparsely to avoid chart junk.
- **No type at an angle**: don’t set type at an angle, nobody wants to twist his neck reading a chart.
- **Direct labeling**: no legend is required for a plot. When possible, use direct labeling. Don’t make your audience do a color-coding exercise.
- **Add chart junk**: didn’t we just argue to keep chart junk to a minimum…? We sure did, but if you want your graph to stand out, a little chart junk can be very effective. A little detail that supports your story, like a little icons, can give it that touch that could make your graph stand out from the crowd. As always, it’s a matter of taste (and corporate design and branding). Optimizing your visual is a step that should not be skipped, a few simple tweaks can make a big difference.

You can [access Astrid's and Joachim's blog post here](https://joachim-gassen.github.io/2020/11/lpockdown-effects/). Astrid and Joachim also gave a workshop on data visualization in November 2020. You can access the slides from this workshop here: [Link to workshop slides](https://trr266.wiwi.hu-berlin.de/cloud/apps/files/?dir=/trr266_all/trr266_c02/events_and_talks/data_viz_wshop&fileid=344903#pdfviewer).


## The function `theme_trr()`

The function can be added like a normal theme to a `ggplot` graph. It takes four optional arguments: `plot_type`, `legend`, `text_size`, and `axis_y_horizontal`.

- `plot_type` can be a barplot (set `plot_type = "bar"`), a boxplot (`plot_type = "box"`), a lollipop plot (`plot_type = "lollipop"`), a line graph (`plot_type = "line"`), a scatter plot (`plot_type = "scatter"`), and/or a smoother plot (`plot_type = "smoother"`). There is a default option for this argument so that you do not have set it. Setting the correct plot type, however, might improve the look of your graph as it activates ggplot settings customized for the plot type.
- `legend` can be set using logical values. The default setting is `legend = FALSE`. `legend = TRUE` adds a legend to ggplot graphs. Note that this should only be used for grouped plots, e.g., a bar graph with bars for each group. 
- `text_size` gives control over the font size of the plot. It is set to `text_size = 21` as a default. This should be adjusted to make text elements more readable.
- Astrid is a big fan of not setting type at an angle and thus, y axis titles will be positioned horizontally be default. I most cases it is advisable not to use y axis titles at all and instead to define the y axis in a subtitle of the graph. If you want a y axis title and you *want* it to be vertical, you can set `axis_y_horizontal` to `FALSE`

You can apply the TRR 266 colors to your ggplot by setting the scales `scale_fill_trr266_d()` and `scale_color_trr266()_d`. The functions `scale_fill/color_trr266_c()` create luminance-based continuous color scales from a base color. See the use cases below for examples.


### Use of `theme_trr()`

The `theme_trr` ggplot theme function provides a uniform and concise function that implements most of the TRR266 style guides on ggplot visualizations. While it can be called on all plots, it is especially designed for six types of plots (ggplot "geoms"), namely: `bar`, `box`, `line`, `lollipop`, `scatter` and `smoother` plots. This document will showcase the main usages of the `theme_trr` function with bar plots and add additional recommended changes while showing the usage of the function on other types of graphs.


### Data for demonstration 

We use the popular mtcars dataset for showcasing the `theme_trr` function. You can find information on the dataset here: [Link to mtcars documentation](https://cran.r-project.org/web/packages/explore/vignettes/explore_mtcars.html).^[The link address to the mtcars dataset documentation: https://cran.r-project.org/web/packages/explore/vignettes/explore_mtcars.html.]

```{r comment=""}
mtcars %>% 
  mutate(cyl = as.factor(cyl),
         am = as.factor(ifelse(am == 0, 'automatic', 'manual'))) -> mtcars
head(mtcars)
```


### Transformation of a Plot: A Bar Graph Story

We start with a bar graph. It plots the transmission of cars (variable `am`), zero for automatic and one for manual, by the number of cylinders of cars  (variable `cyl`) in the `mtcars` dataset. Cars in the dataset have either 4, 6, or 8 cylinders.

```{r}
ggplot(mtcars, aes(cyl, fill = am)) +
  geom_bar(position = "dodge")
```
 
Calling the `theme_trr` function on such a plot will produce the plot below. Several features of the plot change including turning type back from being at an angle, removing axes ticks, and centering the legend above the plot area.

```{r}
ggplot(mtcars, aes(cyl, fill = am)) +
  geom_bar(position = "dodge") +
  theme_trr(plot_type = "bar", legend = TRUE)
```

The `theme_trr` function implements some changes to the first plot, but coloring and spacing is set outside of theme functions. So, next the coloring and the space between the x-axis and bars need adjustments. The `scale_fill_trr266_d` call implements the TRR coloring scheme and the `scale_y_continuous` call removes the extra space between the x-axis line and the plot area.

```{r}
ggplot(mtcars, aes(cyl, fill = am)) +
  geom_bar(position = "dodge") +
  theme_trr(plot_type = "bar", legend = TRUE) +
  scale_fill_trr266_d() +
  scale_y_continuous(expand = expansion(mult = c(0, 0)))
```

Eventually, we adjust the labels of the plot and the text font. The TRR266 style guide recommends the use of the fonts *Calibri Light* and *Cambria*. Both are fonts that come with Microsoft Office distributions. Assuming that you have the necessary fonts on your system, you can use the `showtext` library to import and use the necessary fonts. 

```{r}
library(showtext)

trr266_fonts_available <- all(c("Cambria", "Calibri Light") %in% font_families())

if (!trr266_fonts_available) {
  # On Mac with MS Office installation you need to add the Office
  # Fonts to the font path. The following depends on your 
  # installation but _should_ work in most cases
  
  office_font_path <- "/Applications/Microsoft Word.app/Contents/Resources/DFonts"
  if (Sys.info()["sysname"] == "Darwin") {
    if (dir.exists(office_font_path)) font_paths(office_font_path)
    else stop("MS Office font path not found")
  }
  
  rv <- tryCatch({
    font_add(family = "Cambria", regular = "Cambria.ttc")
    font_add(family = "Calibri Light", regular = "calibril.ttf")
  }, error = function(e) {
    message(sprintf("Failed to install TRR 266 fonts: %s", e))
    invisible(font_families())        
  })
  
  trr266_fonts_available <- all(c("Cambria", "Calibri Light") %in% rv)
  if (trr266_fonts_available) message("Successfully installed TRR 266 fonts") 
}
```


Importing fonts should be necessary only once per session. Once these two fonts have been imported an additional theme call can be made to set the right fonts.

```{r, fig.showtext = TRUE}
if (trr266_fonts_available) {
  showtext_begin()
  print(ggplot(mtcars, aes(cyl, fill = am)) +
    geom_bar(position = "dodge") +
    theme_trr(plot_type = "bar", legend = TRUE) +
    scale_fill_trr266_d() +
    scale_y_continuous(expand = expansion(mult = c(0, 0))) +
    labs(title = "Example bar chart", 
         subtitle = "Transmission type of cars by number of cylinders",
         x = "Number of cylinders",
         y = "Count") +
    theme(
      title = element_text(family = "Cambria"),
      text = element_text(family = "Calibri Light")
    ))
  showtext_end()
}
```


## More `theme_trr` use cases

### Box plot

Reordering factors in an increasing or decreasing order helps highlight the difference between groups. 

```{r}
ggplot(mtcars, aes(x = reorder(cyl, wt), y = wt, color = cyl)) +
  geom_jitter(width = 0.1) +
  geom_boxplot(alpha = 0.25) +
  labs(title = "Example box plot", 
       subtitle = "Weight of cars by number of of cylinders",
       x = "Number of cylinders",
       y = "Weight (1000 lbs)") +
  scale_color_trr266_d() +
  theme_trr(plot_type = "box")
```

### Line graph

When possible, use direct labeling.

```{r}
library(directlabels)

ggplot(mtcars, aes(x = qsec, y = mpg, color = am)) +
  geom_line() +
  labs(title = "Example line graph") +
  scale_color_trr266_d() +
  geom_dl(aes(label = am), method = list("last.points")) +
  theme_trr(plot_type = "line", legend = FALSE) +
  scale_x_continuous(expand = expansion(mult = c(.1, .2)))
```


### Lollipop plots

Lollipop plots help in reducing clutter, especially when there are numerous categories in a factor variable. 

```{r}
group_by(mtcars, carb) %>%
  summarise(mean_mpg = mean(mpg)) %>%
  mutate(carb = fct_reorder(as.character(carb), mean_mpg)) %>%
  ggplot(aes(x = mean_mpg, y = carb)) +
  geom_segment(aes(x = 0, y = carb, xend = mean_mpg, yend = carb)) +
  geom_point(size = 2, color = "#1B8A8FFF") +
  labs(title = "Example lollipop plot") +
  theme_trr(plot_type = "Lollipop")
```

### Scatter plot


```{r }
library(directlabels)

ggplot(mtcars, aes(x = hp, y = mpg, color = am)) +
  geom_point(size = 3, alpha = 0.8) +
  labs(title = "Example scatter plot") +
  scale_color_trr266_d() +
  geom_dl(aes(label = am), method = list("smart.grid", cex = rel(1.1))) +
  theme_trr(plot_type = "scatter")
```

If you need to use a continuous color scale, you can use `scale_fill_trr266_c()` with your favorite TRR 266 color. Also see how we render the y axis text vertically here (sorry Astrid).

```{r}
ggplot(mtcars, aes(x = hp, y = mpg, color = disp)) +
  geom_point(size = 3, alpha = 0.8) +
  labs(title = "Example scatter plot") +
  scale_color_trr266_c(base_color = col_trr266_red) +
  theme_trr(plot_type = "scatter", legend = TRUE, axis_y_horizontal = FALSE)
```


### Smoother plot

```{r }
ggplot(mtcars, aes(x = qsec, y = mpg, color = am)) +
  geom_smooth() +
  labs(title = "Example smoother plot") +
  scale_color_trr266_d() +
  scale_x_continuous(expand = expansion(mult = c(0, .2))) +
  theme_trr(plot_type = "smoother", legend = T)
```


## Troubleshooting

Responsible authors:

- Astrid van Kimmenrade (astrid.van.kimmenade@uni-paderborn.de)
- Fikir Worku Edossa (fikir.worku.edossa@hu-berlin.de)
- Tobias Witter (tobias.witter@hu-berlin.de)

If you have questions or encounter problems using the objects contained in `theme_trr.R`, please contact us via email. Alternatively, you can open an issue in the Git repo, if you have remarks that are of general interest, i.e. also relevant to other users. The following web page describes how to open an issue in a repo, see [how to open an issue on GitHub](https://docs.github.com/en/github/managing-your-work-on-github/creating-an-issue).

