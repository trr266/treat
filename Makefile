# If you are new to Makefiles: https://makefiletutorial.com

PAPER := output/paper/paper.pdf
PRESENTATION := output/presentation/presentation.pdf
TARGETS :=  $(PAPER) $(PRESENTATION)

WRDS_DATA := data/pulled/crsp_a_ccm_link.rds data/pulled/cstat_us_sample.rds \
	data/pulled/rest_data.rds

GENERATED_DATA := data/generated/acc_sample.rds

RSCRIPT := Rscript --encoding=UTF-8

.phony: all clean dist-clean

all: $(TARGETS)

clean:
	rm -f $(TARGETS)
	rm -f output/interim/*
	rm -f data/generated/*
	
dist-clean: clean
	rm -f data/pulled/*
	rm -f ouput/paper/*
	rm -f ouput/presentation/*

$(WRDS_DATA)&: code/R/pull_wrds_data.R code/R/read_config.R config.csv
	$(RSCRIPT) code/R/pull_wrds_data.R

$(GENERATED_DATA): $(WRDS_DATA)
	$(RSCRIPT) code/R/prepare_sample.R
	
$(PAPER): code/R/compile_paper.R $(GENERATED_DATA)
	$(RSCRIPT) code/R/compile_paper.R
	
$(PRESENTATION): code/R/compile_presentation.R $(GENERATED_DATA)
	$(RSCRIPT) code/R/compile_presentation.R	