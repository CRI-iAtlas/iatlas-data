build_patients_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_patients_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_patients <- function() {

    cat(crayon::magenta(paste0("Get patients.")), fill = TRUE)

    cat_samples_status("Get the initial values from Synapse.")
    patients. <- dplyr::tibble(
      barcode = character(),
      age = character(),
      ethinicity = character(),
      gender = character(),
      height = character(),
      race = character(),
      weight = character()
    )

    return(patients.)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$pcawg_patients <- get_patients() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/patients/pcawg_patients.feather"))

  # Log out of Synapse.
  iatlas.data::synapse_logout()

  ### Clean up ###
  # Data
  rm(pcawg_patients, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
