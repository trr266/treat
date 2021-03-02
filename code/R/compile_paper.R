rmarkdown::render(
  input = "paper/paper.Rmd", 
  intermediates_dir = "output/paper",
  output_dir = "output/paper",
  output_file = "paper.pdf",
  clean = TRUE
)