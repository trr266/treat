# Design Principles

The treat repository showcases a programming language agnostic open science workflow that follows the following guiding principles:

1. Reproducibiliy
2. Interoperability
3. Simplicity 


Reproducibility implies that code generated based on this template should be able to be run by anyone, anywhere, at any time. This is achieved through the use of containerization (Docker) and workflow management (Make). The development container included in this template ensures that all necessary dependencies are installed. It can be run either locally (VSCode/Docker) or on GitHub Codespaces.

Interoperability implies that code generated based on this template should be able to use multiple programming languages, and that different parts of the workflow can be written in different languages. This is achieved through the use of Make as a workflow manager, which can call scripts written in any language. The use of YAML configuration files makes it easy to share information between different parts of the workflow. Finally, the use of common data formats (CSV, Parquet) allows for easy data exchange. A common log file approach is used to track the progress of the workflow.

Simplicity implies that code generated based on this template should be easy to understand and use. Researchers with limited programming experience should be able to use this template to create their own workflows. At times, simplicity conflicts with the two other principles. In these cases, reproducibility and interoperability are prioritized over simplicity. However, simplicity takes precedence over other potential principles such as efficiency, scalability, and elegance ;-)

# To Do

- [ ] Switch to serializing functions and data instead of tables and figure outputs (might imply that we have to package the python code)
- [ ] R: Remove dependency on ExPanDaR. Use fixest and modelsummary instead.
- [ ] Python: Rewrite WRDS code to use duckdb. Or, alternatively, use SQL query to merge data server side like in R code. Do we really need the WRDS package? It seems opinonated and not very flexible (password management).
- [ ] Python: Change log messages to be more informative (similar to R code)
- [ ] Python: The log file location variable is currently not used.
- [ ] Include the nested public repo approach
- [ ] Decide how to maintain various template variants (branches? separate repos? core and overlays with CI?)
- [ ] Do we need linting and CI checks?
- [ ] Adjust README to reflect changes in V2.0, including a documentation of how to add additional progamming languages.