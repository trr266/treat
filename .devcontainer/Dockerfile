FROM rocker/r-ver:4.5

ENV DEBIAN_FRONTEND=noninteractive TZ=UTC LANG=C.UTF-8

# System dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      cmake git pandoc wget xz-utils rsync python3-venv curl \
      libxml2-dev libcurl4-openssl-dev libssl-dev libgit2-dev \
      libfontconfig1-dev libharfbuzz-dev libfribidi-dev librsvg2-dev \
      libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev \
      libpq-dev ghostscript \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# R packages
RUN install2.r --error --skipinstalled \
      tidyverse rmarkdown modelsummary gt languageserver \
      fixest glue logger dotenv ggbeeswarm devtools \
      colorspace hms duckdb yaml arrow \
  && Rscript -e "install.packages('vscDebugger', repos='https://manuelhentschel.r-universe.dev')" \
  && rm -rf /tmp/downloaded_packages

# TinyTeX + required LaTeX packages
RUN set -eux; \
  install2.r --error --skipinstalled tinytex; \
  Rscript -e "tinytex::install_tinytex()"; \
  ln -sf /root/bin/* /usr/local/bin/ 

RUN tlmgr install \
    latexmk xetex fontspec ifxetex beamer pgf xcolor graphics graphicx \
    geometry setspace caption footmisc array threeparttable adjustbox \
    csquotes etoolbox kvoptions booktabs endfloat environ ulem \
    cmbright carlito lmodern makecell hyperref xurl babel-english \
    bibtex natbib apsr epstopdf multirow wrapfig colortbl pdflscape tabu \
    threeparttablex extsizes; \
  tlmgr repository

# Quarto 
RUN set -eux; \
  QUARTO_VERSION=1.6.40; \
  ARCH="$(dpkg --print-architecture)"; \
  case "$ARCH" in \
    amd64) QA=linux-amd64 ;; \
    arm64) QA=linux-arm64 ;; \
    *) echo "Unsupported arch: $ARCH" >&2; exit 1 ;; \
  esac; \
  wget -O /tmp/quarto.deb \
    "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-${QA}.deb"; \
  dpkg -i /tmp/quarto.deb; rm /tmp/quarto.deb

# yq (auto-detect arch; avoid ARG)
RUN set -eux; \
  ARCH="$(dpkg --print-architecture)"; \
  case "$ARCH" in \
    amd64) YQ=yq_linux_amd64 ;; \
    arm64) YQ=yq_linux_arm64 ;; \
    *) echo "Unsupported arch: $ARCH" >&2; exit 1 ;; \
  esac; \
  YQ_VERSION=v4.47.2; \
  wget -O /usr/local/bin/yq \
    "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ}"; \
  chmod +x /usr/local/bin/yq

RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && ln -sf /root/.local/bin/uv /usr/local/bin/uv

CMD ["/bin/sh"]