source('R/load_config.R')
load_config(Sys.getenv("R_CONFIG_ACTIVE", unset = "dev"))

devtools::load_all(devtools::as.package(".")$path)
cat(crayon::blue("SUCCESS: iatlas.data package loaded and ready to go.\n"))
cat(crayon::blue(paste0("RUN: ", crayon::bold("build_iatlas_db()\n"))))
cat(crayon::blue(paste0("TEST: ", crayon::bold("devtools::test()\n"))))
