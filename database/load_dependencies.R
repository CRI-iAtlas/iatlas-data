load_dependencies <- function() {
  if (Sys.getenv("RSTUDIO") == "1" | Sys.getenv("DOCKERBUILD") == "1") {
    try(renv::restore(confirm = FALSE))
  }

  ### Only need to load packages that have functionality that is NOT called like pkg::function() ###

  # Load magrittr so %>% is available.
  library("magrittr")
}
