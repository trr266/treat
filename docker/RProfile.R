setHook('rstudio.sessionInit', function(newSession) {
  if (newSession & is.null(rstudioapi::getActiveProject())) {
    rstudioapi::openProject('~/treat')
  }
  rstudioapi::navigateToFile("config.csv", line = 19, column = 11)
  rstudioapi::navigateToFile("README.md", line = 1, column = 1)
}, action = "append")
