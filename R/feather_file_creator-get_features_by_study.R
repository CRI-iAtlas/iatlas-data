get_features_by_study <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  get_features_by_study <- function(study) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    # Get the initial values from the features table.
    features <- current_pool %>% dplyr::tbl("features")

    # Get all sample ids that are related to a feature.
    features <- features %>%
      dplyr::right_join(
        current_pool %>% dplyr::tbl("features_to_samples"),
        by = c("id" = "feature_id")
      )

    # Get all tag ids that the found samples are related to.
    # Then get all the tags those related tags are related to.
    # Finally, filter down to only the features that have samples tagged to the passed study.
    features <- features %>%
      dplyr::right_join(
        current_pool %>% dplyr::tbl("samples_to_tags") %>%
          dplyr::right_join(
            current_pool %>% dplyr::tbl("tags_to_tags") %>%
              dplyr::right_join(
                current_pool %>% dplyr::tbl("tags") %>%
                  dplyr::select(id, study_name = name),
                by = c("related_tag_id" = "id")
              ) %>%
              dplyr::filter(study_name == study),
            by = "tag_id"
          ),
        by = c("id" = "sample_id")
      )

    # Get all the classes related to the features.
    features <- features %>%
      dplyr::left_join(
        current_pool %>% dplyr::tbl("classes") %>%
          dplyr::select(id, class = name),
        by = c("class_id" = "id")
      )

    # Get all the method tags that are related to the features.
    features <- features %>%
      dplyr::left_join(
        current_pool %>% dplyr::tbl("method_tags") %>%
          dplyr::select(id, method_tag = name),
        by = c("method_tag_id" = "id")
      )

    # Clean up the data set.
    features <- features %>%
      dplyr::distinct(class, display, method_tag, name, order, unit) %>%
      dplyr::filter(!is.na(name))

    # Execute the query and return a tibble.
    features <- features %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(features)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_features <- "TCGA_Study" %>%
    get_features_by_study %>%
    feather::write_feather(paste0(getwd(), "/feather_files/features/tcga_study_features.feather"))

  .GlobalEnv$tcga_subtype_features <- "TCGA_Subtype" %>%
    get_features_by_study %>%
    feather::write_feather(paste0(getwd(), "/feather_files/features/tcga_subtype_features.feather"))

  .GlobalEnv$immune_subtype_features <- "Immune_Subtype" %>%
    get_features_by_study %>%
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
