# If you are new to Makefiles: https://makefiletutorial.com

PAPER := output/paper.pdf

PRESENTATION := output/presentation.pdf

TARGETS :=  $(PAPER) $(PRESENTATION)

WRDS_DATA := data/pulled/cstat_us_sample.rds

GENERATED_DATA := data/generated/acc_sample.rds

RESULTS := output/results.rda

RSCRIPT := Rscript --encoding=UTF-8

.phony: all clean very-clean dist-clean

all: $(TARGETS)

clean:
	rm -f $(TARGETS)
	rm -f $(RESULTS)
	rm -f $(GENERATED_DATA)
	
very-clean: clean
	rm -f $(WRDS_DATA)

dist-clean: very-clean
	rm config.csv
	
config.csv:
	@echo "To start, you need to copy _config.csv to config.csv and edit it"
	@false
	
$(WRDS_DATA): code/R/pull_wrds_data.R code/R/read_config.R config.csv
	$(RSCRIPT) code/R/pull_wrds_data.R

$(GENERATED_DATA): $(WRDS_DATA) code/R/prepare_data.R
	$(RSCRIPT) code/R/prepare_data.R

$(RESULTS):	$(GENERATED_DATA) code/R/do_analysis.R
	$(RSCRIPT) code/R/do_analysis.R

$(PAPER): doc/paper.Rmd doc/references.bib $(RESULTS) 
	$(RSCRIPT) -e 'rmarkdown::render("doc/paper.Rmd")'
	mv doc/paper.pdf output
	rm -f doc/paper.ttt doc/paper.fff
	
$(PRESENTATION): doc/presentation.rmd $(RESULTS) 
	$(RSCRIPT) -e 'rmarkdown::render("doc/presentation.Rmd")'
	mv doc/presentation.pdf output
