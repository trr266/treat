FROM rocker/verse:4.1
RUN R -e "install.packages(c('pkg', 'tidyverse', 'modelr', 'broom',  \
                           'lubridate', 'ExPanDaR', 'RPostgres', 'DBI', \
                           'knitr', 'kableExtra', 'rmarkdown', \
                           'tinytex','rstudioapi'))"
                           
RUN tlmgr update --self

RUN tlmgr install amsmath latex-amsmath-dev iftex kvoptions kvsetkeys ltxcmds \
  etoolbox xcolor pdftexcmds infwarerr geometry auxhook endfloat  setspace \
  footmisc caption threeparttable adjustbox collectbox csquotes  booktabs \
  multirow wrapfig float colortbl pdflscape tabu varwidth threeparttablex \
  environ trimspaces ulem makecell epstopdf-pkg amscls beamer fp ms pgf \
  translator extsizes euenc fontspec tipa unicode-math xunicode cmbright \
  texlive-scripts carlito \
  && tlmgr path add

ADD https://api.github.com/repos/trr266/treat/git/refs/heads/main version.json  

RUN cd  /home/rstudio && sudo -H -u rstudio git clone https://github.com/trr266/treat.git

COPY Docker/RProfile.R /home/rstudio/.Rprofile
RUN cp /home/rstudio/treat/_config.csv /home/rstudio/treat/config.csv

RUN chown rstudio.rstudio /home/rstudio/.Rprofile
RUN chown rstudio.rstudio /home/rstudio/treat/config.csv
