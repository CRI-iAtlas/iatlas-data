get_tags_to_tags_by_study <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_tags_to_tags_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_tags_to_tags <- function(study, exlude_study_01, exlude_study_02) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get tags_to_tags by `", study, "`")), fill = TRUE)

    cat_tags_to_tags_status("Get the initial values from the tags_to_tags table.")
    tags_to_tags <- current_pool %>% dplyr::tbl("tags_to_tags")

    cat_tags_to_tags_status("Get the tag names by tag id.")
    tags_to_tags <- tags_to_tags %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, tag = name),
      by = c("tag_id" = "id")
    )

    cat_tags_to_tags_status("Get the related tag names.")
    tags_to_tags <- tags_to_tags %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, related_tag = name),
      by = c("related_tag_id" = "id")
    )

    cat_tags_to_tags_status("Filter the data set to tags related to the passed study.")
    tags_to_tags <- tags_to_tags %>%
      dplyr::filter(
        tag != exlude_study_01 & related_tag != exlude_study_01 & tag != exlude_study_02 & related_tag != exlude_study_02
      )

    cat_tags_to_tags_status("Clean up the data set.")
    tags_to_tags <- tags_to_tags %>%
      dplyr::distinct(tag, related_tag) %>%
      dplyr::arrange(tag, related_tag)

    cat_tags_to_tags_status("Execute the query and return a tibble.")
    tags_to_tags <- tags_to_tags %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(tags_to_tags)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_tags_to_tags <- "TCGA_Study" %>%
    get_tags_to_tags("TCGA_Subtype", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/tags_to_tags/tcga_study_tags_to_tags.feather"))

  .GlobalEnv$tcga_subtype_tags_to_tags <- "TCGA_Subtype" %>%
    get_tags_to_tags("TCGA_Study", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/tags_to_tags/tcga_subtype_tags_to_tags.feather"))

  .GlobalEnv$immune_subtype_tags_to_tags <- "Immune_Subtype" %>%
    get_tags_to_tags("TCGA_Study", "TCGA_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/tags_to_tags/immune_subtype_tags_to_tags.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tcga_study_tags_to_tags, pos = ".GlobalEnv")
  rm(tcga_subtype_tags_to_tags, pos = ".GlobalEnv")
  rm(immune_subtype_tags_to_tags, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
