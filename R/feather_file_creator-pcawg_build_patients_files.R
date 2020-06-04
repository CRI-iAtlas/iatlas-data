pcawg_build_patients_files <- function() {

  cat_patients_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_patients <- function() {

    cat(crayon::magenta(paste0("Get PCAWG patients.")), fill = TRUE)

    cat_patients_status("Get the initial values from Synapse.")
    patients <- iatlas.data::get_pcawg_samples_cached() %>%
      dplyr::select(barcode = sample)

    return(patients)
  }

  .GlobalEnv$pcawg_patients <- iatlas.data::synapse_store_feather_file(
    get_patients(),
    "pcawg_patients.feather",
    "syn22125717"
  )

  # Log out of Synapse.
  iatlas.data::synapse_logout()

  ### Clean up ###
  # Data
  rm(pcawg_patients, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
