get_samples_by_study <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  get_samples_by_study <- function(study) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    # Get the initial values from the samples table.
    samples <- current_pool %>% dplyr::tbl("samples")

    # Get tag ids related to the samples.
    samples <- samples %>% dplyr::right_join(
      current_pool %>% dplyr::tbl("samples_to_tags"),
      by = c("id" = "sample_id")
    )

    # Get the tag names for the samples by tag id.
    samples <- samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, tag_name = name),
      by = c("tag_id" = "id")
    )

    # Get tag ids related to the tags :)
    samples <- samples %>% dplyr::right_join(
      current_pool %>% dplyr::tbl("tags_to_tags"),
      by = "tag_id"
    )

    # Get the related tag names for the samples by related tag id.
    samples <- samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, related_tag_name = name),
      by = c("related_tag_id" = "id")
    )

    # Filter the data set to tags related to the passed study.
    samples <- samples %>% dplyr::filter(tag_name == study | related_tag_name == study)

    # Get the patient data from the patients table.
    samples <- samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("patients") %>%
        dplyr::rename(patient_barcode = barcode),
      by = c("patient_id" = "id")
    )

    # Get the slide ids for each patient id related to the samples.
    samples <- samples %>% dplyr::inner_join(
      current_pool %>% dplyr::tbl("patients_to_slides"),
      by = "patient_id"
    )

    # Get the slide ids for each patient id related to the samples.
    samples <- samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("slides") %>%
        dplyr::rename(slide = name) %>%
        dplyr::rename(slide_description = description),
      by = c("slide_id" = "id")
    )

    # Clean up the data set.
    samples <- samples %>%
      dplyr::distinct(name, patient_barcode, age, ethnicity, gender, race, weight, slide, slide_description) %>%
      dplyr::arrange(name)

    # Execute the query and return a tibble.
    samples <- samples %>% dplyr::as_tibble()

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
