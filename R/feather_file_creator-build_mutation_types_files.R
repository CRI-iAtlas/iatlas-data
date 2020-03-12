build_mutation_types_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_mutation_types_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_type <- function(type) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get mutation_type `", type, "`")), fill = TRUE)

    cat_mutation_types_status("Get the initial values from the mutation_types table.")
    mutation_types <- current_pool %>% dplyr::tbl("mutation_types")

    cat_mutation_types_status("Limit to only the passed type.")
    mutation_types <- mutation_types %>% dplyr::filter(name == type)

    cat_mutation_types_status("Clean up the data set.")
    mutation_types <- mutation_types %>%
      dplyr::distinct(name, display) %>%
      dplyr::filter(!is.na(name)) %>%
      dplyr::arrange(name)

    cat_mutation_types_status("Execute the query and return a tibble.")
    mutation_types <- mutation_types %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(mutation_types)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$driver_mutation <- "driver_mutation" %>%
    get_type %>%
    feather::write_feather(paste0(getwd(), "/feather_files/mutation_types/driver_mutation_mutation_type.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(driver_mutation, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
