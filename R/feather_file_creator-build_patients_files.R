build_patients_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_patients_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_patients <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get patients.")), fill = TRUE)

    cat_patients_status("Get the initial values from the patients table.")
    patients <- current_pool %>% dplyr::tbl("patients")

    cat_patients_status("Get sample ids related to the patients.")
    patients <- patients %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("samples") %>%
        dplyr::select(sample_id = id, patient_id),
      by = c("id" = "patient_id")
    )

    cat_patients_status("Clean up the data set.")
    patients <- patients %>%
      dplyr::distinct(barcode, age, ethnicity, gender, height, race, weight) %>%
      dplyr::arrange(barcode)

    cat_patients_status("Execute the query and return a tibble.")
    patients <- patients %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(patients)
  }

  all_patients <- get_patients()
  all_patients <- all_patients %>% split(rep(1:3, each = ceiling(length(all_patients)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$patients_01 <- all_patients %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/patients/patients_01.feather"))

  .GlobalEnv$patients_02 <- all_patients %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/patients/patients_02.feather"))

  .GlobalEnv$patients_03 <- all_patients %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/patients/patients_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(patients_01, pos = ".GlobalEnv")
  rm(patients_02, pos = ".GlobalEnv")
  rm(patients_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
