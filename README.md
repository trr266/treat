# The TRR 266 Template for Reproducible Empirical Accounting Research


This repository provides an infrastructure for open science oriented empirical projects. While it is targeted to the empirical accounting research crowd, it should appeal to every economist working with observational data. It features a toy project exploring discretionary accruals of U.S. public firms and requires access to U.S. Compustat data via WRDS.

But even if you do not care about discretionary accruals (who wouldn’t? 😉) or do not have WRDS access, its code base should give you a feel on how the template is supposed to be used and how to structure a reproducible empirical project.

## Design principles

The treat repository showcases a programming language agnostic open science workflow that follows the following guiding principles:

1.  Reproducibiliy
2.  Interoperability
3.  Simplicity

**Reproducibility** implies that code generated based on this template should be able to be run by anyone, anywhere, at any time. This is achieved through the use of containerization (Docker) and workflow management (Make). The development container included in this template ensures that all necessary dependencies are installed. It can be run either locally (VSCode/Docker) or on GitHub Codespaces.

**Interoperability** implies that different parts of the workflow can use different programming languages. This is achieved through the use of Make as a workflow manager, which can call scripts written in any language. The use of YAML configuration files facilitates sharing information between different parts of the workflow. Finally, the use of common data formats (CSV, Parquet) allows for cross-language data exchange. A common log file approach is used to track the progress of the workflow.

**Simplicity** implies that code generated based on this template should be easy to understand and use. Researchers with limited programming experience should be able to use this template to create their own workflows. At times, simplicity conflicts with the two other principles. In these cases, reproducibility and interoperability are prioritized over simplicity. However, simplicity takes precedence over other potential principles such as efficiency, scalability, and elegance ;-)

## Where do I start?

To start, use this repository as a template to create a your own repository (See the ‘Use this template’ button on GitHub?).

Then, you will have to take a decision. If you have a local development environment with Python and/or R installed, it might be tempting to use it as your development platform. However, to ensure that your work will be reproducible by others (or even yourself in the future), we would strongly encourage you to use this template in a development container.

## Using the template in a development container

To use the template in a development container, you have (at least) two options:

- Using GitHub Codespaces (zero local setup required): To set the repo up in a development container on GitHub Codespaces, go to the GitHub homepage of your new repository and click on “Code/Codespace/Start new Codespace on main”. See [here](https://github.com/features/codespaces) to learn more about GitHub Codespaces.
- Using Visual Studio Code and Docker locally (Docker and VS Code need to be installed): You can open the repository in a container in VS Code by following [these instructions](https://code.visualstudio.com/docs/remote/containers-tutorial).

## Using the template in your local development environment

To run the code locally, you need to have Python, quarto and R installed. Also, you need to have several unix (`make`, `touch`, `cp`, `rm`, `rsync`, `yq`, …) commands available in your terminal. There are various ways to achieve this and given that you want to run the repo locally, you most likely will have a preference for one of those.

This is the Session Info of the R environment that we are currently using in our develpopment container:

``` r
source("code/R/utils.R")
sessionInfo()
```

    R version 4.5.1 (2025-06-13)
    Platform: aarch64-unknown-linux-gnu
    Running under: Ubuntu 24.04.2 LTS

    Matrix products: default
    BLAS:   /usr/lib/aarch64-linux-gnu/openblas-pthread/libblas.so.3 
    LAPACK: /usr/lib/aarch64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0

    locale:
     [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
     [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
     [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
    [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   

    time zone: UTC
    tzcode source: system (glibc)

    attached base packages:
    [1] stats     graphics  grDevices utils     datasets  methods   base     

    other attached packages:
     [1] gt_1.1.0           fixest_0.13.2      modelsummary_2.5.0 arrow_21.0.0.1    
     [5] duckdb_1.4.0       DBI_1.2.3          hms_1.1.3          lubridate_1.9.4   
     [9] broom_1.0.10       modelr_0.1.11      purrr_1.1.0        ggplot2_4.0.0     
    [13] tidyr_1.3.1        dplyr_1.1.4        readr_2.1.5        yaml_2.3.10       
    [17] dotenv_1.0.3       glue_1.8.0         logger_0.4.1      

    loaded via a namespace (and not attached):
     [1] sandwich_3.1-1      generics_0.1.4      xml2_1.4.0         
     [4] lattice_0.22-7      dreamerr_1.5.0      digest_0.6.37      
     [7] magrittr_2.0.4      evaluate_1.0.5      grid_4.5.1         
    [10] timechange_0.3.0    RColorBrewer_1.1-3  fastmap_1.2.0      
    [13] jsonlite_2.0.0      backports_1.5.0     Formula_1.2-5      
    [16] scales_1.4.0        stringmagic_1.2.0   numDeriv_2016.8-1.1
    [19] cli_3.6.5           rlang_1.1.6         bit64_4.6.0-1      
    [22] withr_3.0.2         tools_4.5.1         tzdb_0.5.0         
    [25] assertthat_0.2.1    vctrs_0.6.5         R6_2.6.1           
    [28] zoo_1.8-14          lifecycle_1.0.4     fs_1.6.6           
    [31] bit_4.6.0           pkgconfig_2.0.3     pillar_1.11.1      
    [34] gtable_0.3.6        Rcpp_1.1.0          data.table_1.17.8  
    [37] xfun_0.53           tibble_3.3.0        tidyselect_1.2.1   
    [40] knitr_1.50          farver_2.1.2        nlme_3.1-168       
    [43] htmltools_0.5.8.1   tables_0.9.31       rmarkdown_2.30     
    [46] compiler_4.5.1      S7_0.2.0           

And this our current Python version:

``` python
import sys
print(sys.version)
```

    3.12.3 (main, Aug 14 2025, 17:47:21) [GCC 13.3.0]

You can find the list of required Python packages in the `requirements.txt` file. You can install them using `pip install -r requirements.txt` (see below).

## Repository Content

Browse around the repository and familiarize yourself with its folders. You will quickly see that there are several folders:

- `config`: This directory holds configuration files that are being called by the code files in the `code` directory. We try to keep the configurations separate from the code to make it easier to adjust the workflow to your needs.

- `code`: Here you will the find the R and Python code base. Both programming language folders contain all code necessary to run our showcase project. The files are being called to download data from WRDS, prepare the data, run the analysis and create the results for the output files (a paper and a presentation, both PDF files).

- `data`: A directory where data is stored. You will see that it again contains sub-directories and a README file that explains their purpose. You will also see that in the `external` sub-directory there are two data files. Again, the README file explains their content.

- `doc`: Here you will find Quarto files containing text and program instructions that will become our paper and presentation. Again, there is a Python and an R variant.

- `info`: This is a folder that can store additional documentation. In our case you will find a RMarkdown file that introduces our TRR 266-themed ggplot theme.

You also see an `output` directory but it is empty. Why? Because you will create the output by running the code in the repository, if you want. Read on to learn how.

## How do I run the showcase code and create the output?

Assuming that you have WRDS access to Compustat North America, this should be relatively straightforward.

1.  Create a virtual environment for the project. You can do this by running `python3 -m venv .venv` in the terminal. This will create a virtual environment in the `.venv` directory. You can activate the virtual environment by running `source .venv/bin/activate` on MacOS or Linux or `.\.venv\Scripts\activate` on Windows. You can deactivate the virtual environment by running `deactivate`.
2.  With an active virtual environment, you can install the required packages by running `pip install -r requirements.txt` in the terminal. This will install the required Python packages for the project.
3.  Copy the file `_secrets.env` to `secrets.env` in the project main directory. Edit it by adding your WRDS credentials.
4.  Run `make all` via the terminal. This will partly use the R code and the Python code to demonstrate the mixed programming workflow. Alternatively, you can also run `make all -f Makefile_python` to only use the Python code base or run `make all -f Makefile_R` to build only based on R.
5.  Eventually, you will be greeted with two files in the output directory: `treat_paper.pdf` and `treat_presentation.pdf`. Congratulations! You have successfully used an open science resource and reproduced our “analysis”. Now modify it and make it your own project!

## OK. That was fun. Bot how should I use the repo now?

The basic idea is to clone the repository whenever you start a new project. If you are using GitHub, the simplest way to do this is to click on “Use this Template” above the file list. Then delete everything that you don’t like and/or need. Over time, as you develop your own preferences, you can fork this repository and adjust it so that it becomes your very own template targeted to your very own preferences.

## For TRR 266 Members: What else is in there for you?

This repository contains three files that TRR members that use R might find particularly useful. The file `code/R/theme_trr.R` features a ggplot theme that makes it easy to generate visuals that comply to the TRR 266 style guide. The RMarkdown file in `info` takes you through the process. With the `doc/beamer_theme_trr266.sty` or `doc/beamer_theme_trr266_16x9.sty` latex macros you can beef up your Quarto based beamer presentations to our fancy TRR design. Finally, the R and Python code files that download WRDS data might be useful if you want to familiarize yourself with the process.

## Why do you do abc in a certain way? I like to do things differently!

Scientific workflows are a matter of preference and taste. What we present here is based on our design principles outlined above and on our experiences on what works well in the short run while generating long-term reproducible software pipelines. But this by no means implies that there are no other and better ways to do things. So, feel free to disagree and to build your own template. Or, even better: Convince us about your approach by submitting a pull request!

## But there are other templates. Why yet another one?

Of course there are and many of them are great. The reason why we decided to whip up our own is that we wanted a template that also includes some of the default style elements that we use in our collaborative research center [TRR 266 Accounting for Transparency](https://accounting-for-transparency.de). And we wanted to have a template that is centered on workflows that are typical in the accounting and finance domain. Here you go.

## Licensing

This repository is licensed to you under the MIT license, essentially meaning that you can do whatever you want with it as long as you give credit to us when you use substantial portions of it. What ‘substantial’ means is not trivial for a template. Here is our understanding. If you ‘only’ use the workflow, the structure and let’s say parts of the Makefile and/or the README sections that describe these aspects, we do not consider this as ‘substantial’ and you do not need to credit us. If, however, you decide to reuse a significant part of the example code, for example the code pulling data from WRDS, we think that giving credit would be appropriate.

In any case, we would love to see you spreading the word by adding a statement like

    This repository was built based on the ['treat' template for reproducible research](https://github.com/trr266/treat).

to your README file. But this is not a legal requirement but a favor that we ask 😉.

## References

These are some very helpful texts discussing collaborative workflows for scientific computing:

- Christensen, Freese and Miguel (2019): Transparent and Reproducible Social Science Research, Chapter 11, https://www.ucpress.edu/book/9780520296954/transparent-and-reproducible-social-science-research
- Gentzkow and Shapiro (2014): Code and data for the social sciences: a practitioner’s guide, https://web.stanford.edu/~gentzkow/research/CodeAndData.pdf
- Gow and Ding: Empirical Research in Accounting: Tools and Methods, Appendicies C to E, https://iangow.github.io/far_book/
- Wilson, Bryan, Cranston, Kitzes, Nederbragt and Teal (2017): Good enough practices in scientific computing, PLOS Computational Biology 13(6): 1-20, https://doi.org/10.1371/journal.pcbi.1005510
