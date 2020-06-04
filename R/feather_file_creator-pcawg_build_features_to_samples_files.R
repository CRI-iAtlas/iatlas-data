pcawg_build_features_to_samples_files <- function() {

  cat_features_to_samples_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_features_to_samples <- function() {

    cat(crayon::magenta(paste0("Get PCAWG features_to_samples")), fill = TRUE)

    cat_features_to_samples_status("Get the initial values from Synapse.")
    features_to_samples <- iatlas.data::get_pcawg_feature_values_cached()

    cat_features_to_samples_status("Ensure features use underscores instead of dots.")
    features_to_samples <- features_to_samples %>% dplyr::mutate(feature = stringr::str_replace_all(feature, "[\\.]", "_"))

    cat_features_to_samples_status("Clean up the data set.")
    features_to_samples <- features_to_samples %>%
      dplyr::distinct(feature, sample, value) %>%
      dplyr::arrange(feature, sample)

    return(features_to_samples)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$pcawg_features_to_samples <- get_features_to_samples() %>%
    feather::write_feather(., "pcawg_features_to_samples.feather")

  iatlas.data::synapse_store_file("pcawg_features_to_samples.feather", "syn22125635")
  file.remove("pcawg_features_to_samples.feather")

  # Log out of Synapse.
  iatlas.data::synapse_logout()

  ### Clean up ###
  # Data
  rm(pcawg_features_to_samples, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
