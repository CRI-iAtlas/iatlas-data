build_samples_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_samples_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_samples <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get samples.")), fill = TRUE)

    cat_samples_status("Get the initial values from the samples table.")
    samples <- current_pool %>% dplyr::tbl("samples")

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

  all_samples <- get_samples()
  all_samples <- all_samples %>% split(rep(1:3, each = ceiling(length(all_samples)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$samples_01 <- all_samples %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/samples/samples_01.feather"))

  .GlobalEnv$samples_02 <- all_samples %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/samples/samples_02.feather"))

  .GlobalEnv$samples_03 <- all_samples %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/samples/samples_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(samples_01, pos = ".GlobalEnv")
  rm(samples_02, pos = ".GlobalEnv")
  rm(samples_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
