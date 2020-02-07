build_features_to_samples_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_features_to_samples_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_features_to_samples <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get features_to_samples")), fill = TRUE)

    cat_features_to_samples_status("Get the initial values from the features_to_samples table.")
    features_to_samples <- current_pool %>% dplyr::tbl("features_to_samples")

    cat_features_to_samples_status("Merge the value field and the inf_value field into a single value field.")
    features_to_samples <- features_to_samples %>%
      dplyr::mutate(value = ifelse(!is.na(value), value, inf_value))

    cat_features_to_samples_status("Get the features from the features table.")
    features_to_samples <- features_to_samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("features") %>%
        dplyr::select(id, feature = name),
      by = c("feature_id" = "id")
    )

    cat_features_to_samples_status("Get the samples from the samples table.")
    features_to_samples <- features_to_samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("samples") %>%
        dplyr::select(id, sample = name),
      by = c("sample_id" = "id")
    )

    cat_features_to_samples_status("Clean up the data set.")
    features_to_samples <- features_to_samples %>%
      dplyr::distinct(feature, sample, value) %>%
      dplyr::arrange(feature, sample)

    cat_features_to_samples_status("Execute the query and return a tibble.")
    features_to_samples <- features_to_samples %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(features_to_samples)
  }

  all_features_to_samples <- get_features_to_samples()
  all_features_to_samples <- all_features_to_samples %>% split(rep(1:3, each = ceiling(length(all_features_to_samples)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$features_to_samples_01 <- all_features_to_samples %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/features_to_samples/features_to_samples_01.feather"))

  .GlobalEnv$features_to_samples_02 <- all_features_to_samples %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/features_to_samples/features_to_samples_02.feather"))

  .GlobalEnv$features_to_samples_03 <- all_features_to_samples %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/features_to_samples/features_to_samples_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(features_to_samples_01, pos = ".GlobalEnv")
  rm(features_to_samples_02, pos = ".GlobalEnv")
  rm(features_to_samples_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
