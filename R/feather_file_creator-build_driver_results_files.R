build_driver_results_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_results_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_results <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get driver results")), fill = TRUE)

    cat_results_status("Get the initial values from the driver_results table.")
    driver_results <- current_pool %>% dplyr::tbl("driver_results")

    cat_results_status("Get features related to the driver results.")
    driver_results <- driver_results %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("features") %>%
        dplyr::select(feature_id = id, feature = name),
      by = "feature_id"
    )

    cat_results_status("Get genes related to the driver results.")
    driver_results <- driver_results %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("genes") %>%
        dplyr::select(gene_id = id, entrez),
      by = "gene_id"
    )

    cat_results_status("Get mutation codes related to the driver results.")
    driver_results <- driver_results %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("mutation_codes") %>%
        dplyr::select(mutation_code_id = id, mutation_code = code),
      by = "mutation_code_id"
    )

    cat_results_status("Get tags related to the driver results.")
    driver_results <- driver_results %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, tag = name),
      by = c("tag_id" = "id")
    )

    cat_results_status("Clean up the data set.")
    driver_results <- driver_results %>% dplyr::distinct(entrez, feature, mutation_code, tag, p_value, fold_change, log10_p_value, log10_fold_change, n_wt, n_mut)

    cat_results_status("Execute the query and return a tibble.")
    driver_results <- driver_results %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(driver_results)
  }

  all_driver_results <- get_results()
  all_driver_results <- all_driver_results %>%
    split(rep(1:3, each = ceiling(length(all_driver_results)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$driver_results_01 <- all_driver_results %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/driver_results/driver_results_01.feather"))

  .GlobalEnv$driver_results_02 <- all_driver_results %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/driver_results/driver_results_02.feather"))

  .GlobalEnv$driver_results_03 <- all_driver_results %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/driver_results/driver_results_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(driver_results_01, pos = ".GlobalEnv")
  rm(driver_results_02, pos = ".GlobalEnv")
  rm(driver_results_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
