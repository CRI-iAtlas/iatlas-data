source('R/load_config.R')
devtools::load_all(devtools::as.package(".")$path)

load_config(Sys.getenv("R_CONFIG_ACTIVE", unset = "dev"))
cat(crayon::blue("SUCCESS: iatlas.data package loaded and ready to go.\n"))
cat(crayon::blue("For more info, open README.md\n"))
cat(crayon::blue(paste0("TEST: ",crayon::bold("devtools::test()\n"))))
cat(crayon::blue(paste0("RUN:  ",crayon::bold("iatlas.data::build_all()\n"))))
