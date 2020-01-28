try(startup::startup())
devtools::load_all(devtools::as.package(".")$path)
cat(crayon::blue("SUCCESS: iatlas.data package loaded and ready to go.\n"))
cat(crayon::blue(paste0("RUN: ",crayon::bold("iatlas.data::build_iatlas_db(reset='reset')\n"))))