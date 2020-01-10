if (Sys.getenv("RSTUDIO") == "1" | Sys.getenv("DOCKERBUILD") == "1") {
  try(source("renv/activate.R"))
  try(install.packages("startup"))
}


# Attempt to run startup
try(startup::startup())

if (Sys.getenv("RSTUDIO") == "1" | Sys.getenv("DOCKERBUILD") == "1") {
  try(renv::restore())
}
