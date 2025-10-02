# To Dos

- [X] R: Remove dependency on ExPanDaR. Use fixest and modelsummary instead.
- [X] Python: The figures are not rendered in the output objects (caused by new quarto version I guess)
- [X] Python: The data preparation step currently fails on GitHub Codespaces (memory issue - fixed by requiring 16GB runners)
- [ ] Python: The R2s reported in the regression table look off and do not match the R findings
- [ ] Python: What about singletons? Compare to R table.
- [ ] Python: Rewrite WRDS code to use duckdb. Or, alternatively, use SQL query to merge data server side like in R code. Do we really need the WRDS package? It seems opinonated and not very flexible (password management).
- [ ] Python: Rewrite analysis code to not mimic the ExPanDaR approach but to use state of the art general purpose Python packages for fixed effect OLS and table generation
- [X] Python: Change log messages to be more informative (similar to R code)
- [X] Python: The log file location variable is currently not used
- [ ] Python: Adjust the paper and presentation to more closely match the R output
- [ ] Include the nested public repo approach
- [ ] Decide how to maintain various template variants (branches? separate repos? core and overlays with CI? Cookiecutter?)
- [ ] To consider: Switch to serializing functions and data instead of tables and figure outputs (might imply that we have to package the python code, not sure whether it is needed at this stage. The R approach still works and requiring all result objects to be calculated at output render time might make the process less convenient for the user)
- [ ] To consider: Do we need linting and CI checks?
- [ ] To consider: How about some exemplary unit checks? For example for verifying sample integrity?
- [ ] Adjust README to reflect changes in V2.0, including a documentation of how to add additional progamming languages.