get_features_by_study <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_features_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_features <- function(study, exclude01, exclude02) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get features by `", study, "`")), fill = TRUE)

    cat_features_status("Get the initial values from the features table.")
    features <- current_pool %>% dplyr::tbl("features")

    cat_features_status("Get all sample ids that are related to a feature.")
    features <- features %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("features_to_samples"),
      by = c("id" = "feature_id")
    )

    cat_features_status("Get all tag ids that the found samples are related to.")
    features <- features %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("samples_to_tags"),
      by = c("id" = "sample_id")
    )

    cat_features_status("Then get all the tag ids those related tags are related to.")
    features <- features %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags_to_tags"),
      by = "tag_id"
    )

    cat_features_status("Get all the related tags that the found samples are related to.")
    features <- features %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, study_name = name),
      by = c("related_tag_id" = "id")
    )

    cat_features_status("Limit to only the features that have samples tagged to the passed study.")
    features <- features %>% dplyr::filter(
      study_name != exclude01 & study_name != exclude02
    )

    cat_features_status("Get all the classes related to the features.")
    features <- features %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("classes") %>%
        dplyr::select(id, class = name),
      by = c("class_id" = "id")
    )

    cat_features_status("Get all the method tags that are related to the features.")
    features <- features %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("method_tags") %>%
        dplyr::select(id, method_tag = name),
      by = c("method_tag_id" = "id")
    )

    cat_features_status("Clean up the data set.")
    features <- features %>%
      dplyr::distinct(name, display, class, method_tag, order, unit) %>%
      dplyr::filter(!is.na(name)) %>%
      dplyr::arrange(name)

    cat_features_status("Execute the query and return a tibble.")
    features <- features %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(features)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_features <- "TCGA_Study" %>%
    get_features("TCGA_Subtype", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/features/tcga_study_features.feather"))

  .GlobalEnv$tcga_subtype_features <- "TCGA_Subtype" %>%
    get_features("TCGA_Study", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/features/tcga_subtype_features.feather"))

  .GlobalEnv$immune_subtype_features <- "Immune_Subtype" %>%
    get_features("TCGA_Study", "TCGA_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/features/immune_subtype_features.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tcga_study_features, pos = ".GlobalEnv")
  rm(tcga_subtype_features, pos = ".GlobalEnv")
  rm(immune_subtype_features, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
