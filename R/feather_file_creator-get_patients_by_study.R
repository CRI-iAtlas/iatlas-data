get_patients_by_study <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_patients_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_patients <- function(study, exclude01, exclude02) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get patients by `", study, "`")), fill = TRUE)

    cat_patients_status("Get the initial values from the patients table.")
    patients <- current_pool %>% dplyr::tbl("patients")

    cat_patients_status("Get sample ids related to the patients.")
    patients <- patients %>% dplyr::full_join(
      current_pool %>% dplyr::tbl("samples") %>%
        dplyr::select(sample_id = id, patient_id),
      by = c("id" = "patient_id")
    )

    cat_patients_status("Get tag ids related to the samples.")
    patients <- patients %>% dplyr::full_join(
      current_pool %>% dplyr::tbl("samples_to_tags"),
      by = c("id" = "sample_id")
    )

    cat_patients_status("Get the tag names for the samples by tag id.")
    patients <- patients %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, tag_name = name),
      by = c("tag_id" = "id")
    )

    cat_patients_status("Get tag ids related to the tags :)")
    patients <- patients %>% dplyr::full_join(
      current_pool %>% dplyr::tbl("tags_to_tags"),
      by = "tag_id"
    )

    cat_patients_status("Get the related tag names for the samples by related tag id.")
    patients <- patients %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, related_tag_name = name),
      by = c("related_tag_id" = "id")
    )

    cat_patients_status("Filter the data set to tags related to the passed study.")
    patients <- patients %>% dplyr::filter(
      tag_name == study | related_tag_name == study |
        (tag_name != exclude01 & related_tag_name == exclude01 &
           tag_name != exclude02 & related_tag_name == exclude02)
    )

    cat_patients_status("Clean up the data set.")
    patients <- patients %>%
      dplyr::distinct(barcode, age, ethnicity, gender, race, weight) %>%
      dplyr::arrange(barcode)

    cat_patients_status("Execute the query and return a tibble.")
    patients <- patients %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(patients)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_patients <- "TCGA_Study" %>%
    get_patients("TCGA_Subtype", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/patients/tcga_study_patients.feather"))

  .GlobalEnv$tcga_subtype_patients <- "TCGA_Subtype" %>%
    get_patients("TCGA_Study", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/patients/tcga_subtype_patients.feather"))

  .GlobalEnv$immune_subtype_patients <- "Immune_Subtype" %>%
    get_patients("TCGA_Study", "TCGA_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/patients/immune_subtype_patients.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tcga_study_patients, pos = ".GlobalEnv")
  rm(tcga_subtype_patients, pos = ".GlobalEnv")
  rm(immune_subtype_patients, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
