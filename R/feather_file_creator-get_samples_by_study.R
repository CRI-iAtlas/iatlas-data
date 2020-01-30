get_samples_by_study <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  get_samples_by_study <- function(study) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    samples <- current_pool %>%
      dplyr::tbl("samples") %>%
      dplyr::right_join(
        current_pool %>%
          dplyr::tbl("samples_to_tags"),
        by = c("id" = "sample_id")
      ) %>%
      dplyr::left_join(
        current_pool %>%
          dplyr::tbl("tags") %>%
          dplyr::select(id, name) %>%
          dplyr::rename_at("name", ~("tag_name")),
        by = c("tag_id" = "id")
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
      dplyr::select(name, tissue_id) %>%
      dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(samples)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_samples <- "TCGA_Study" %>%
    get_samples_by_study %>%
    feather::write_feather(paste0(getwd(), "/feather_files/samples/tcga_study_samples.feather"))

  .GlobalEnv$tcga_subtype_samples <- "TCGA_Subtype" %>%
    get_samples_by_study %>%
    feather::write_feather(paste0(getwd(), "/feather_files/samples/tcga_subtype_samples.feather"))

  .GlobalEnv$immune_subtype_samples <- "Immune_Subtype" %>%
    get_samples_by_study %>%
    feather::write_feather(paste0(getwd(), "/feather_files/samples/immune_subtype_samples.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tcga_study_samples, pos = ".GlobalEnv")
  rm(tcga_subtype_samples, pos = ".GlobalEnv")
  rm(immune_subtype_samples, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
