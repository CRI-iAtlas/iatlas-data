get_tags_by_study <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  get_tags_by_study <- function(study) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    # Get initial data from the tags table.
    tags <- current_pool %>% dplyr::tbl("tags")

    # Get all related tag ids for each tag in the table.
    # Then get all the related tags from the tags table.
    # Finally, filter down the tags to only tags related to the passed study.
    tags <- tags %>%
      dplyr::right_join(
        current_pool %>%
          dplyr::tbl("tags_to_tags") %>%
          dplyr::right_join(
            current_pool %>% dplyr::tbl("tags") %>%
              dplyr::select(id, related_tag_name = name),
            by = c("related_tag_id" = "id")) %>%
          dplyr::filter(related_tag_name == study),
        by = c("id" = "tag_id")
      )

    # Clean up the data set.
    tags <- tags %>% dplyr::distinct(name, characteristics, display, color)

    # Execute the query and return a tibble.
    tags <- tags %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(tags)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_tags <- "TCGA_Study" %>%
    get_tags_by_study %>%
    feather::write_feather(paste0(getwd(), "/feather_files/tags/tcga_study_tags.feather"))

  .GlobalEnv$tcga_subtype_tags <- "TCGA_Subtype" %>%
    get_tags_by_study %>%
    feather::write_feather(paste0(getwd(), "/feather_files/tags/tcga_subtype_tags.feather"))

  .GlobalEnv$immune_subtype_tags <- "Immune_Subtype" %>%
    get_tags_by_study %>%
    feather::write_feather(paste0(getwd(), "/feather_files/tags/immune_subtype_tags.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  # rm(tcga_study_tags, pos = ".GlobalEnv")
  # rm(tcga_subtype_tags, pos = ".GlobalEnv")
  # rm(immune_subtype_tags, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
