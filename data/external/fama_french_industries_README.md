The two data files "fama_french_12_industries.csv" and "fama_french_48_industries.csv" are look-up files that help to match Standard Industry Classifiers (SIC) codes to industry classifications used by Fama and French for their industry portfolios (http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html).

Both files are organized as comma separated value files with the first row containing the variable names. They have two columns: The first column lists the SIC codes and the second column lists the respective industry name. Thus, they can easily be matched with SIC codes that come with firm level data.

Two things are worth mentioning:

- Please never forget: SIC codes look like numeric variables but they are not. They are discrete factors. It is good policy to treat them this way, also because otherwise they will loose their leading.
- Both Fama/French industry classifications do not map the whole SIC universe into industries. You will have firms that cannot be matched. 