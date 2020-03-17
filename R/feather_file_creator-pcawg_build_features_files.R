pcawg_build_features_files <- function() {

  cat_features_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_features <- function() {

    cat(crayon::magenta(paste0("Get features")), fill = TRUE)

    cat_features_status("Get the initial values from Synapse.")
    features <- iatlas.data::get_pcawg_features_cached()
    features_to_samples <- iatlas.data::get_pcawg_feature_values_cached() %>%
      dplyr::select(name = feature)

    cat_features_status("Bind all the features together.")
    features <- features %>% dplyr::bind_rows(features_to_samples)

    cat_features_status("Ensure feature names use underscores instead of dots.")
    features <- features %>% dplyr::mutate(name = stringr::str_replace_all(name, "[\\.]", "_"))

    cat_features_status("Clean up the data set.")
    features <- features %>%
      dplyr::distinct(name, display, unit, class) %>%
      dplyr::arrange(name)

    return(features)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$pcawg_features <- get_features() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/features/pcawg_features.feather"))

  # Log out of Synapse.
  iatlas.data::synapse_logout()

  ### Clean up ###
  # Data
  rm(pcawg_features, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
