pcawg_build_features_files <- function() {

  cat_features_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_features <- function() {

    cat(crayon::magenta(paste0("Get features")), fill = TRUE)

    cat_features_status("Get the initial values from Synapse.")
    features <- iatlas.data::get_pcawg_feature_values_cached()

    # Workflow output »  Deconvolution »  MCPCounter » SP101526.tsv
    # sample should match to sample name. Each additional column should be a feature.
    # name should be mpc_counter_<feature_name_no_spaces>
    # display should be as the column name

    # Samples_to_features can be captued from these files as well.

    # class ==  MCPCounter or Epic (depending on the folder)

    return(features)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$pcawg_features <- get_features() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/features/pcawg_features.feather"))

  # Log out of Synapse.
  iatlas.data::synapse_logout()

  ### Clean up ###
  # Data
  # rm(pcawg_features, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
