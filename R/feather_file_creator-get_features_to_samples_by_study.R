get_features_to_samples_by_study <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  get_features_to_samples_by_study <- function(study) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    features_to_samples <- current_pool %>%
      dplyr::tbl("features_to_samples") %>%
      dplyr::left_join(
        current_pool %>%
          dplyr::tbl("samples_to_tags"),
        by = "sample_id"
      ) %>%
      dplyr::right_join(
        current_pool %>%
          dplyr::tbl("tags_to_tags") %>%
          dplyr::right_join(
            current_pool %>%
              dplyr::tbl("tags") %>%
              dplyr::select(id, name),
            by = c("related_tag_id" = "id")) %>%
          dplyr::filter(name == study),
        by = "tag_id"
      ) %>%
      dplyr::left_join(
        current_pool %>%
          dplyr::tbl("features") %>%
          dplyr::select(id, name) %>%
          dplyr::rename_at("name", ~("feature")),
        by = c("feature_id" = "id")
      ) %>%
      dplyr::left_join(
        current_pool %>%
          dplyr::tbl("samples") %>%
          dplyr::select(id, name) %>%
          dplyr::rename_at("name", ~("sample")),
        by = c("sample_id" = "id")
      ) %>%
      dplyr::distinct(feature, sample, value, inf_value) %>%
      dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(features_to_samples)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_features_to_samples <- "TCGA_Study" %>%
    get_features_to_samples_by_study %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/features_to_samples/tcga_study_features_to_samples.feather"))

  .GlobalEnv$tcga_subtype_features_to_samples <- "TCGA_Subtype" %>%
    get_features_to_samples_by_study %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/features_to_samples/tcga_subtype_features_to_samples.feather"))

  .GlobalEnv$immune_subtype_features_to_samples <- "Immune_Subtype" %>%
    get_features_to_samples_by_study %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/features_to_samples/immune_subtype_features_to_samples.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tcga_study_features_to_samples, pos = ".GlobalEnv")
  rm(tcga_subtype_features_to_samples, pos = ".GlobalEnv")
  rm(immune_subtype_features_to_samples, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
