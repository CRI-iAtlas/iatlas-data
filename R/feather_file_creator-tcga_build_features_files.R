tcga_build_features_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_features_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_features <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get features")), fill = TRUE)

    cat_features_status("Get the initial values from the features table.")
    features <- current_pool %>% dplyr::tbl("features")

    cat_features_status("Get all the classes related to the features.")
    features <- features %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("classes") %>%
        dplyr::select(class_id = id, class = name),
      by = "class_id"
    )

    cat_features_status("Get all the method tags that are related to the features.")
    features <- features %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("method_tags") %>%
        dplyr::select(method_tag_id = id, method_tag = name),
      by = "method_tag_id"
    )

    cat_features_status("Clean up the data set.")
    features <- features %>%
      dplyr::filter(!is.na(name)) %>%
      dplyr::distinct(name, display, class, method_tag, order, unit) %>%
      dplyr::arrange(name)

    cat_features_status("Execute the query and return a tibble.")
    features <- features %>% dplyr::as_tibble()

    cat_features_status("Ensure feature names use underscores instead of dots.")
    features <- features %>% dplyr::mutate(name = stringr::str_replace_all(name, "[\\.]{1,}", "_"))

    cat_features_status("Clean up the data set.")
    features <- features %>%
      dplyr::distinct(name, display, class, method_tag, order, unit) %>%
      dplyr::arrange(name)

    pool::poolReturn(current_pool)

    return(features)
  }

  all_features <- get_features()
  all_features <- all_features %>% split(rep(1:3, each = ceiling(length(all_features)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$features_01 <- all_features %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/features/features_01.feather"))

  .GlobalEnv$features_02 <- all_features %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/features/features_02.feather"))

  .GlobalEnv$features_03 <- all_features %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/features/features_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(features_01, pos = ".GlobalEnv")
  rm(features_02, pos = ".GlobalEnv")
  rm(features_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
