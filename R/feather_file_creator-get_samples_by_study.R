get_samples_by_study <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_samples_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_samples <- function(study, exclude01, exclude02) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get samples by `", study, "`")), fill = TRUE)

    cat_samples_status("Get the initial values from the samples table.")
    samples <- current_pool %>% dplyr::tbl("samples")

    cat_samples_status("Get tag ids related to the samples.")
    samples <- samples %>% dplyr::full_join(
      current_pool %>% dplyr::tbl("samples_to_tags"),
      by = c("id" = "sample_id")
    )

    cat_samples_status("Get the tag names for the samples by tag id.")
    samples <- samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, tag_name = name),
      by = c("tag_id" = "id")
    )

    cat_samples_status("Get tag ids related to the tags :)")
    samples <- samples %>% dplyr::full_join(
      current_pool %>% dplyr::tbl("tags_to_tags"),
      by = "tag_id"
    )

    cat_samples_status("Get the related tag names for the samples by related tag id.")
    samples <- samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, related_tag_name = name),
      by = c("related_tag_id" = "id")
    )

    cat_samples_status("Filter the data set to tags related to the passed study.")
    samples <- samples %>% dplyr::filter(
      tag_name == study | related_tag_name == study |
        (tag_name != exclude01 & related_tag_name == exclude01 &
           tag_name != exclude02 & related_tag_name == exclude02)
    )

    cat_samples_status("Get the patient data from the patients table.")
    samples <- samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("patients") %>%
        dplyr::rename(patient_barcode = barcode),
      by = c("patient_id" = "id")
    )

    cat_samples_status("Clean up the data set.")
    samples <- samples %>%
      dplyr::distinct(name, patient_barcode) %>%
      dplyr::arrange(name)

    cat_samples_status("Execute the query and return a tibble.")
    samples <- samples %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(samples)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_samples <- "TCGA_Study" %>%
    get_samples("TCGA_Subtype", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/samples/tcga_study_samples.feather"))

  .GlobalEnv$tcga_subtype_samples <- "TCGA_Subtype" %>%
    get_samples("TCGA_Study", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/samples/tcga_subtype_samples.feather"))

  .GlobalEnv$immune_subtype_samples <- "Immune_Subtype" %>%
    get_samples("TCGA_Study", "TCGA_Subtype") %>%
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
