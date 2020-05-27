setHook("rstudio.sessionInit", function(newSession) {
  if (newSession && is.null(rstudioapi::getActiveProject()))
    rstudioapi::openProject("./iatlas-data.Rproj")
}, action = "append")

if (file.exists("renv/activate.R")) {
  source("renv/activate.R")

  cat("
  --------------------------------------------------------------------------------
  Welcome to the iAtlas Database Loader
  --------------------------------------------------------------------------------
  \n")

  # Check to see if we're running in Gitlab
  IS_CI <- Sys.getenv("CI", unset = "")

  if (IS_CI != "1" && (length(find.package("devtools", quiet = T)) == 0 || length(find.package("renv", quiet = T)) == 0)) {
    # prompt instead since RStudio won't show progress for slow .RProfile scripts...
    cat("TODO: Install package requirements. This may take up to an hour the first time.\n")
    cat("RUN: source('./install.R')\n")
  } else {
    # auto-run since it should be quick, but makes sure any new requirements are installed.
    source('./install.R')
  }

  rm(IS_CI) 
}

