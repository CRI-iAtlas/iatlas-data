pcawg_build_samples_files <- function() {

  cat_samples_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_samples <- function() {

    cat(crayon::magenta(paste0("Get PCAWG samples.")), fill = TRUE)

    cat_samples_status("Get the initial values from Synapse.")
    samples <- iatlas.data::get_pcawg_samples_cached() %>%
      dplyr::select(patient_barcode = sample) %>%
      dplyr::mutate(name = patient_barcode)

    return(samples)
  }

  .GlobalEnv$pcawg_patients <- iatlas.data::synapse_store_feather_file(
    get_samples(),
    "pcawg_samples.feather",
    "syn22125724"
  )

  # Log out of Synapse.
  iatlas.data::synapse_logout()

  ### Clean up ###
  # Data
  rm(pcawg_samples, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
