get_mutation_codes <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_mutation_codes_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_codes <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get mutation_codes")), fill = TRUE)

    cat_mutation_codes_status("Get the initial values from the mutation_codes table.")
    mutation_codes <- current_pool %>% dplyr::tbl("mutation_codes")

    cat_mutation_codes_status("Clean up the data set.")
    mutation_codes <- mutation_codes %>%
      dplyr::distinct(code) %>%
      dplyr::filter(!is.na(code)) %>%
      dplyr::arrange(code)

    cat_mutation_codes_status("Execute the query and return a tibble.")
    mutation_codes <- mutation_codes %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(mutation_codes)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$mutation_codes <- get_codes() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/mutation_codes/tcga_mutation_codes.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(mutation_codes, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
