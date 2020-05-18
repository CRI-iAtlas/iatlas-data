tcga_build_mutation_types_files <- function() {
  cat_mutation_types_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_type <- function() {
    cat(crayon::magenta(paste0("Build tcga mutation types.")), fill = TRUE)

    mutation_types <- dplyr::tibble(name = "driver_mutation", display = "Driver Mutation")

    return(mutation_types)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$driver_mutation <- get_type() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/mutation_types/driver_mutation_mutation_type.feather"))

  ### Clean up ###
  # Data
  rm(driver_mutation, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
