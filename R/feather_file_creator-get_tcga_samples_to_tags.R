get_tcga_samples_to_tags <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  get_tcga_samples_to_tags <- function(study) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    samples_to_tags <- current_pool %>%
      dplyr::tbl("samples_to_tags") %>%
      dplyr::right_join(
        current_pool %>%
          dplyr::tbl("tags_to_tags") %>%
          dplyr::right_join(
            current_pool %>%
              dplyr::tbl("tags") %>%
              dplyr::select(id, name) %>%
              dplyr::rename_at("name", ~("study_name")),
            by = c("related_tag_id" = "id")
          ) %>%
          dplyr::filter(study_name == study),
        by = "tag_id"
      ) %>%
      dplyr::left_join(
        current_pool %>%
          dplyr::tbl("samples") %>%
          dplyr::select(id, name) %>%
          dplyr::rename_at("name", ~("sample")),
        by = c("related_tag_id" = "id")
      ) %>%
      dplyr::left_join(
        current_pool %>%
          dplyr::tbl("tags") %>%
          dplyr::select(id, name) %>%
          dplyr::rename_at("name", ~("tag")),
        by = c("tag_id" = "id")
      ) %>%
      dplyr::distinct(sample, tag) %>%
      dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(samples_to_tags)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_samples_to_tags <- "TCGA_Study" %>%
    get_tcga_samples_to_tags %>%
    feather::write_feather(paste0(getwd(), "/feather_files/samples/tcga_study_samples_to_tags.feather"))

  .GlobalEnv$tcga_subtype_samples_to_tags <- "TCGA_Subtype" %>%
    get_tcga_samples_to_tags %>%
    feather::write_feather(paste0(getwd(), "/feather_files/samples/tcga_subtype_samples_to_tags.feather"))

  .GlobalEnv$immune_subtype_samples_to_tags <- "Immune_Subtype" %>%
    get_tcga_samples_to_tags %>%
    feather::write_feather(paste0(getwd(), "/feather_files/samples/immune_subtype_samples_to_tags.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tcga_study_samples_to_tags, pos = ".GlobalEnv")
  rm(tcga_subtype_samples_to_tags, pos = ".GlobalEnv")
  rm(immune_subtype_samples_to_tags, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
