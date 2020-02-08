build_patients_to_slides_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_patients_to_slides_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_patients_to_slides <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get patients_to_slides.")), fill = TRUE)

    cat_patients_to_slides_status("Get the initial values from the patients_to_slides table.")
    patients_to_slides <- current_pool %>% dplyr::tbl("patients_to_slides")

    cat_patients_to_slides_status("Get the patient data from the patients table.")
    patients_to_slides <- patients_to_slides %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("patients") %>%
        dplyr::select(patient_id = id, barcode),
      by = "patient_id"
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

  all_patients_to_slides <- get_patients_to_slides()
  all_patients_to_slides <- all_patients_to_slides %>%
    split(rep(1:3, each = ceiling(length(all_patients_to_slides)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$patients_to_slides_01 <- all_patients_to_slides %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/patients_to_slides/patients_to_slides_01.feather"))

  .GlobalEnv$patients_to_slides_02 <- all_patients_to_slides %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/patients_to_slides/patients_to_slides_02.feather"))

  .GlobalEnv$patients_to_slides_03 <- all_patients_to_slides %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/patients_to_slides/patients_to_slides_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(patients_to_slides_01, pos = ".GlobalEnv")
  rm(patients_to_slides_02, pos = ".GlobalEnv")
  rm(patients_to_slides_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
