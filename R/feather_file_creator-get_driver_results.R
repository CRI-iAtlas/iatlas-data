get_driver_results <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  get_results <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    # Get the initial values from the driver_results table.
    driver_results <- current_pool %>% dplyr::tbl("driver_results")

    # Get features related to the driver results.
    driver_results <- driver_results %>% dplyr::left_join(
        current_pool %>% dplyr::tbl("features") %>%
          dplyr::select(id, feature = name),
        by = c("feature_id" = "id")
      )

    # Get genes related to the driver results.
    driver_results <- driver_results %>% dplyr::left_join(
        current_pool %>% dplyr::tbl("genes") %>%
          dplyr::select(id, hgnc),
        by = c("gene_id" = "id")
      )

    # Get tags related to the driver results.
    driver_results <- driver_results %>% dplyr::left_join(
        current_pool %>% dplyr::tbl("tags") %>%
          dplyr::select(id, tag = name),
        by = c("tag_id" = "id")
      )

    # Clean up the data set.
    driver_results <- driver_results %>% dplyr::distinct(feature, hgnc, tag, p_value, fold_change, log10_p_value, log10_fold_change, n_wt, n_mut)

    # Execute the query and return a tibble.
    driver_results <- driver_results %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(driver_results)
  }

  # Setting this to the GlobalEnv just for development purposes.
  .GlobalEnv$driver_results <- get_results() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/driver_results/driver_results.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(driver_results, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
