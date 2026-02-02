# The TRR 266 Template for Reproducible Empirical Accounting Research


This repository provides an infrastructure for open science oriented empirical projects. While it is targeted to the empirical accounting research crowd, it should appeal to every economist working with observational data. It features a toy project exploring discretionary accruals of U.S. public firms and requires access to U.S. Compustat data via WRDS.

But even if you do not care about discretionary accruals (who wouldn’t? 😉) or do not have WRDS access, its code base should give you a feel on how the template is supposed to be used and how to structure a reproducible empirical project.

## Where do I start?

The easiest way to use this repository is to treat it as a starting point for your own project.

First, go to the GitHub page of this repository and click **Use this template** to create a new repository under your account (or your organization). Give it a name, create it, and then switch over to working in *that new repo* (not in `trr266/treat` itself).

From there, you basically have three ways to get into a “ready-to-run” setup where R, Python, Quarto, LaTeX, and the necessary system libraries are already consistent across machines:

-   **Using GitHub Codespaces (zero local setup required):** Go to the GitHub homepage of your new repository and click on “Code/Codespace/Start new Codespace on main”. See [here](https://github.com/features/codespaces) to learn more about GitHub Codespaces.
-   **VS Code + Docker (local, but containerized):** If you work locally, install Docker and VS Code (with the Dev Containers extension). Then clone your new repository, open it in VS Code, and choose `Dev Containers: Reopen in Container` from the Command Palette.. You can learn more about dev containers from [this tutorial](https://code.visualstudio.com/docs/remote/containers-tutorial).
-   **Custom local setup (no containerization):** If you’d rather run everything directly on your machine without containerization, you *can* do that too — it just means you’ll need to install all dependencies manually. More on that later.

If everything works, the following commands should print out the versions of R, Python, Quarto, and Make that are installed in your environment:

``` bash

R --version
```

    R version 4.5.2 (2025-10-31) -- "[Not] Part in a Rumble"
    Copyright (C) 2025 The R Foundation for Statistical Computing
    Platform: x86_64-pc-linux-gnu

    R is free software and comes with ABSOLUTELY NO WARRANTY.
    You are welcome to redistribute it under the terms of the
    GNU General Public License versions 2 or 3.
    For more information about these matters see
    https://www.gnu.org/licenses/.

``` bash
python --version
```

    Python 3.12.3

``` bash
quarto --version
```

    1.6.40

``` bash
make --version
```

    GNU Make 4.3
    Built for x86_64-pc-linux-gnu
    Copyright (C) 1988-2020 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.

## How do I run the showcase and create the output?

Once you have setup the environment, and assuming that you have WRDS access to Compustat North America, this should be relatively straightforward.

### 1) Add your WRDS credentials

This project expects your WRDS login credentials in a local secrets file.

Copy the template file:

``` bash
cp _secrets.env secrets.env
```

Open `secrets.env` and replace the placeholders:

``` text
WRDS_USERNAME=...
WRDS_PASSWORD=...
```

That file is intentionally ignored by Git — it should stay local.

### 2) Run the workflow

From the repository root, just run:

``` bash
make
```

That’s it. The Makefile will take care of pulling the data (via WRDS), preparing the sample, running the analysis, and rendering the paper and presentation.

When it finishes, you should find:

-   `output/treat_paper.pdf`
-   `output/treat_presentation.pdf`

### 3) Want only Python or only R?

By default, `make` runs the mixed-language workflow. If you’d rather stick to one language pipeline, you can run:

``` bash
make -f Makefile_python
```

or:

``` bash
make -f Makefile_R
```

Everything else stays the same.

## Repository Content

Browse around the repository and familiarize yourself with its folders. You will quickly see that there are several folders:

-   `config`: This directory holds configuration files that are being called by the code files in the `code` directory. We try to keep the configurations separate from the code to make it easier to adjust the workflow to your needs.

-   `code`: Here you will the find the R and Python code base. Both programming language folders contain all code necessary to run our showcase project. The files are being called to download data from WRDS, prepare the data, run the analysis and create the results for the output files (a paper and a presentation, both PDF files).

-   `data`: A directory where data is stored. You will see that it again contains sub-directories and a README file that explains their purpose. You will also see that in the `external` sub-directory there are two data files. Again, the README file explains their content.

-   `doc`: Here you will find Quarto files containing text and program instructions that will become our paper and presentation. Again, there is a Python and an R variant.

-   `info`: This is a folder that can store additional documentation. In our case you will find a RMarkdown file that introduces our TRR 266-themed ggplot theme.

You also see an `output` directory but it is empty. Why? Because you will create the output by running the code in the repository, if you want. Read on to learn how.

## Design principles

The treat repository showcases a programming language agnostic open science workflow that follows the following guiding principles:

1.  Reproducibility
2.  Interoperability
3.  Simplicity

**Reproducibility** implies that code generated based on this template should be able to be run by anyone, anywhere, at any time. This is achieved through the use of containerization (Docker) and workflow management (Make). The development container included in this template ensures that all necessary dependencies are installed. It can be run either locally (VSCode/Docker) or on GitHub Codespaces.

**Interoperability** implies that different parts of the workflow can use different programming languages. This is achieved through the use of Make as a workflow manager, which can call scripts written in any language. The use of YAML configuration files facilitates sharing information between different parts of the workflow. Finally, the use of common data formats (CSV, Parquet) allows for cross-language data exchange. A common log file approach is used to track the progress of the workflow.

**Simplicity** implies that code generated based on this template should be easy to understand and use. Researchers with limited programming experience should be able to use this template to create their own workflows. At times, simplicity conflicts with the two other principles. In these cases, reproducibility and interoperability are prioritized over simplicity. However, simplicity takes precedence over other potential principles such as efficiency, scalability, and elegance ;-)

------------------------------------------------------------------------

## LLM-friendly repo prompt

If you want a quick, guided walkthrough or Q&A with your LLM of choice, see `info/LLM_ASSISTANT_SPEC.txt`. It contains a ready-to-use prompt plus a concatenated snapshot of the most important files in this repository. Paste it into your LLM and ask about the Makefile workflow, data pipeline, Quarto outputs, devcontainers, or how to adapt the template to your own project.

## Running outside the dev environment

To run the code locally outside of the development container, you need to have Python, quarto and R installed. Also, you need to have several unix (`make`, `touch`, `cp`, `rm`, `rsync`, `yq`, …) commands available in your terminal. There are various ways to achieve this and given that you want to run the repo locally, you most likely will have a preference for one of those.

This is the Session Info of the R environment that we are currently using in our development container:

``` r
source("code/R/utils.R")
sessionInfo()
```

    R version 4.5.2 (2025-10-31)
    Platform: x86_64-pc-linux-gnu
    Running under: Ubuntu 24.04.3 LTS

    Matrix products: default
    BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0

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
     [1] gt_1.3.0           fixest_0.13.2      modelsummary_2.5.0 arrow_23.0.0      
     [5] duckdb_1.4.4       DBI_1.2.3          hms_1.1.4          lubridate_1.9.4   
     [9] broom_1.0.12       modelr_0.1.11      purrr_1.2.1        ggplot2_4.0.1     
    [13] tidyr_1.3.2        dplyr_1.1.4        readr_2.1.6        yaml_2.3.12       
    [17] dotenv_1.0.3       glue_1.8.0         logger_0.4.1      

    loaded via a namespace (and not attached):
     [1] sandwich_3.1-1      generics_0.1.4      xml2_1.5.2         
     [4] lattice_0.22-7      dreamerr_1.5.0      digest_0.6.39      
     [7] magrittr_2.0.4      evaluate_1.0.5      grid_4.5.2         
    [10] timechange_0.4.0    RColorBrewer_1.1-3  fastmap_1.2.0      
    [13] jsonlite_2.0.0      backports_1.5.0     Formula_1.2-5      
    [16] scales_1.4.0        stringmagic_1.2.0   numDeriv_2016.8-1.1
    [19] cli_3.6.5           rlang_1.1.7         bit64_4.6.0-1      
    [22] withr_3.0.2         otel_0.2.0          tools_4.5.2        
    [25] tzdb_0.5.0          assertthat_0.2.1    vctrs_0.7.1        
    [28] R6_2.6.1            zoo_1.8-15          lifecycle_1.0.5    
    [31] fs_1.6.6            bit_4.6.0           pkgconfig_2.0.3    
    [34] pillar_1.11.1       gtable_0.3.6        Rcpp_1.1.1         
    [37] data.table_1.18.2.1 xfun_0.56           tibble_3.3.1       
    [40] tidyselect_1.2.1    knitr_1.51          farver_2.1.2       
    [43] nlme_3.1-168        htmltools_0.5.9     tables_0.9.33      
    [46] rmarkdown_2.30      compiler_4.5.2      S7_0.2.1           

And this our current Python version:

``` python
import sys
print(sys.version)
```

    3.12.3 (main, Jan  8 2026, 11:30:50) [GCC 13.3.0]

### Python dependencies

This repository is set up for dependency management via `pyproject.toml`.

If you use `uv`:

``` bash
uv sync
source .venv/bin/activate
```

If you use `pip`, create and activate a venv and install dependencies from the project metadata as you prefer.

## OK. That was fun. But how should I use the repo now?

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

-   Christensen, Freese and Miguel (2019): Transparent and Reproducible Social Science Research, Chapter 11, https://www.ucpress.edu/book/9780520296954/transparent-and-reproducible-social-science-research
-   Gentzkow and Shapiro (2014): Code and data for the social sciences: a practitioner’s guide, https://web.stanford.edu/~gentzkow/research/CodeAndData.pdf
-   Gow and Ding: Empirical Research in Accounting: Tools and Methods, Appendicies C to E, https://iangow.github.io/far_book/
-   Wilson, Bryan, Cranston, Kitzes, Nederbragt and Teal (2017): Good enough practices in scientific computing, PLOS Computational Biology 13(6): 1-20, https://doi.org/10.1371/journal.pcbi.1005510
