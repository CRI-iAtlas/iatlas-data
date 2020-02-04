get_patients_to_slides_by_study <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_patients_to_slides_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_patients_to_slides <- function(study, exclude01, exclude02) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get patients_to_slides by `", study, "`")), fill = TRUE)

    cat_patients_to_slides_status("Get the initial values from the patients_to_slides table.")
    patients_to_slides <- current_pool %>% dplyr::tbl("patients_to_slides")

    cat_patients_to_slides_status("Get the patient data from the patients table.")
    patients_to_slides <- patients_to_slides %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("patients") %>%
        dplyr::select(patient_id = id, barcode),
      by = "patient_id"
    )

    cat_patients_to_slides_status("Get sample ids related to the patients.")
    patients_to_slides <- patients_to_slides %>% dplyr::full_join(
      current_pool %>% dplyr::tbl("samples") %>%
        dplyr::select(sample_id = id, patient_id),
      by = "patient_id"
    )

    cat_patients_to_slides_status("Get tag ids related to the samples.")
    patients_to_slides <- patients_to_slides %>% dplyr::full_join(
      current_pool %>% dplyr::tbl("samples_to_tags"),
      by = "sample_id"
    )

    cat_patients_to_slides_status("Get the tag names for the samples by tag id.")
    patients_to_slides <- patients_to_slides %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, tag_name = name),
      by = c("tag_id" = "id")
    )

    cat_patients_to_slides_status("Get tag ids related to the tags :)")
    patients_to_slides <- patients_to_slides %>% dplyr::full_join(
      current_pool %>% dplyr::tbl("tags_to_tags"),
      by = "tag_id"
    )

    cat_patients_to_slides_status("Get the related tag names for the samples by related tag id.")
    patients_to_slides <- patients_to_slides %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, related_tag_name = name),
      by = c("related_tag_id" = "id")
    )

    cat_patients_to_slides_status("Filter the data set to tags related to the passed study.")
    patients_to_slides <- patients_to_slides %>% dplyr::filter(
      tag_name == study | related_tag_name == study |
        (tag_name != exclude01 & related_tag_name == exclude01 &
           tag_name != exclude02 & related_tag_name == exclude02)
    )

    cat_patients_to_slides_status("Get the slide ids for each patient id related to the patients_to_slides.")
    patients_to_slides <- patients_to_slides %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("slides") %>%
        dplyr::select(slide_id = id, slide = name),
      by = "slide_id"
    )

    cat_patients_to_slides_status("Clean up the data set.")
    patients_to_slides <- patients_to_slides %>%
      dplyr::distinct(barcode, slide) %>%
      dplyr::arrange(barcode, slide)

    cat_patients_to_slides_status("Execute the query and return a tibble.")
    patients_to_slides <- patients_to_slides %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(patients_to_slides)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_patients_to_slides <- "TCGA_Study" %>%
    get_patients_to_slides("TCGA_Subtype", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/patients_to_slides/tcga_study_patients_to_slides.feather"))

  .GlobalEnv$tcga_subtype_patients_to_slides <- "TCGA_Subtype" %>%
    get_patients_to_slides("TCGA_Study", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/patients_to_slides/tcga_subtype_patients_to_slides.feather"))

  .GlobalEnv$immune_subtype_patients_to_slides <- "Immune_Subtype" %>%
    get_patients_to_slides("TCGA_Study", "TCGA_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/patients_to_slides/immune_subtype_patients_to_slides.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tcga_study_patients_to_slides, pos = ".GlobalEnv")
  rm(tcga_subtype_patients_to_slides, pos = ".GlobalEnv")
  rm(immune_subtype_patients_to_slides, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
