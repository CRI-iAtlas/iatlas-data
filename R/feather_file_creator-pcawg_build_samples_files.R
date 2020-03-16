pcawg_build_samples_files <- function() {

  cat_samples_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_samples <- function() {

    cat(crayon::magenta(paste0("Get PCAWG samples.")), fill = TRUE)

    cat_samples_status("Get the initial values from Synapse.")
    samples <- iatlas.data::get_pcawg_samples_synapse_cached() %>%
      dplyr::select(patient_barcode = icgc_donor_id) %>%
      dplyr::mutate(name = patient_barcode)

    return(samples)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$pcawg_samples <- get_samples() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/samples/pcawg_samples.feather"))

  # Log out of Synapse.
  iatlas.data::synapse_logout()

  ### Clean up ###
  # Data
  rm(pcawg_samples, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
