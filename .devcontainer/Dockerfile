FROM rocker/r-ver:4.5

RUN apt clean && apt update 
RUN apt-get -y install cmake git pandoc libxml2-dev libcurl4-openssl-dev && apt-get clean
RUN apt-get -y install libssl-dev libgit2-dev wget libfontconfig1-dev && apt-get clean
RUN apt-get -y install libharfbuzz-dev libfribidi-dev librsvg2-dev && apt-get clean
RUN apt-get -y install libfreetype6-dev libpng-dev libtiff5-dev 
RUN apt-get -y install libpq-dev libjpeg-dev && apt-get clean
RUN apt-get -y install texlive && apt-get clean
RUN apt-get -y install texlive-latex-extra && apt-get clean
RUN apt-get -y install texlive-xetex && apt-get clean
RUN apt-get -y install texlive-science && apt-get clean
RUN apt-get -y install texlive-fonts-extra && apt-get clean
RUN apt-get -y install ghostscript && apt-get clean
RUN apt-get -y install python3.12-venv && apt-get clean
RUN apt-get -y install xz-utils && apt-get clean

RUN install2.r --error --skipinstalled tidyverse 
RUN install2.r --error --skipinstalled rmarkdown
RUN install2.r --error --skipinstalled knitr 
RUN install2.r --error --skipinstalled kableExtra
RUN install2.r --error --skipinstalled modelsummary 
RUN install2.r --error --skipinstalled gt
RUN install2.r --error --skipinstalled languageserver
RUN install2.r --error --skipinstalled fixest
RUN install2.r --error --skipinstalled glue
RUN install2.r --error --skipinstalled logger
RUN install2.r --error --skipinstalled dotenv
RUN install2.r --error --skipinstalled readxl
RUN install2.r --error --skipinstalled ggbeeswarm
RUN install2.r --error --skipinstalled devtools
RUN install2.r --error --skipinstalled RPostgres
RUN install2.r --error --skipinstalled ExPanDaR
RUN install2.r --error --skipinstalled colorspace
RUN install2.r --error --skipinstalled hms
RUN install2.r --error --skipinstalled duckdb
RUN install2.r --error --skipinstalled yaml
RUN install2.r --error --skipinstalled arrow
RUN Rscript -e "install.packages('vscDebugger', repos = 'https://manuelhentschel.r-universe.dev')"

RUN rm -rf /tmp/downloaded_packages


ARG TARGETARCH
RUN QUARTO_VERSION=1.6.40 \
    && if [ $TARGETARCH = "arm64" ]; then \
        QUARTO_ARCH=linux-arm64; \
        else QUARTO_ARCH=linux-amd64; \
    fi \
    && wget -O quarto.deb https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-${QUARTO_ARCH}.deb \
    && dpkg -i quarto.deb \
    && rm quarto.deb

# Install yq for parsing yaml cfg files from the Makefile
ARG YQ_VERSION=v4.47.2
ARG YQ_BINARY=yq_linux_${TARGETARCH}
RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY} \
    -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq


# Only needed for the private repository
RUN apt-get -y install rsync && apt-get clean

CMD /bin/sh


