tcag_build_features_to_samples_files <- function() {

  get_features_to_samples <- function() {

    cat(crayon::magenta(paste0("Get features_to_samples")), fill = TRUE)

    create_global_synapse_connection()

    features <- "syn22127418" %>%
      .GlobalEnv$synapse$get() %>%
      purrr::pluck("path") %>%
      feather::read_feather(.) %>%
      dplyr::pull("name") %>%
      unique()

    features_to_samples <- "syn22128019" %>%
      .GlobalEnv$synapse$get() %>%
      purrr::pluck("path") %>%
      feather::read_feather(.) %>%
      dplyr::select("sample" = "ParticipantBarcode", where(is.numeric)) %>%
      dplyr::mutate("Tumor_fraction" = 1 - Stromal_Fraction) %>%
      tidyr::pivot_longer(-"sample", names_to = "feature") %>%
      tidyr::drop_na() %>%
      dplyr::mutate(feature = stringr::str_replace_all(feature, "[\\.]", "_")) %>%
      dplyr::filter(feature %in% features) %>%
      dplyr::arrange(feature, sample) %>%
      dplyr::select("feature", "sample", "value")

    return(features_to_samples)
  }

  .GlobalEnv$tcga_features_to_samples <- iatlas.data::synapse_store_feather_file(
    get_features_to_samples(),
    "tcga_features_to_samples.feather",
    "syn22125635"
  )

  ### Clean up ###
  # Data
  rm(tcga_features_to_samples, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
