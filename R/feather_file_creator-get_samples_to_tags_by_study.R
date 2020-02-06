get_samples_to_tags_by_study <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_samples_to_tags_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_samples_to_tags <- function(study, exclude01, exclude02) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get samples_to_tags by `", study, "`")), fill = TRUE)

    cat_samples_to_tags_status("Get the initial values from the samples_to_tags table.")
    samples_to_tags <- current_pool %>% dplyr::tbl("samples_to_tags")

    cat_samples_to_tags_status("Get the tag names for the samples by tag id.")
    samples_to_tags <- samples_to_tags %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, tag = name),
      by = c("tag_id" = "id")
    )

    cat_samples_to_tags_status("Get tag ids related to the tags :)")
    samples_to_tags <- samples_to_tags %>% dplyr::full_join(
      current_pool %>% dplyr::tbl("tags_to_tags"),
      by = "tag_id"
    )

    cat_samples_to_tags_status("Get the related tag names for the samples by related tag id.")
    samples_to_tags <- samples_to_tags %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, related_tag = name),
      by = c("related_tag_id" = "id")
    )

    cat_samples_to_tags_status("Filter the data set to tags related to the passed study.")
    samples_to_tags <- samples_to_tags %>% dplyr::filter(
      tag == study | related_tag == study |
        (tag != exclude01 & related_tag == exclude01 &
           tag != exclude02 & related_tag == exclude02)
    )

    cat_samples_to_tags_status("Get the sample names.")
    samples_to_tags <- samples_to_tags %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("samples") %>%
        dplyr::select(id, sample = name),
      by = c("sample_id" = "id")
    )

    cat_samples_to_tags_status("Clean up the data set.")
    samples_to_tags <- samples_to_tags %>%
      dplyr::distinct(sample, tag) %>%
      dplyr::arrange(sample, tag)

    cat_samples_to_tags_status("Execute the query and return a tibble.")
    samples_to_tags <- samples_to_tags %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(samples_to_tags)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_samples_to_tags <- "TCGA_Study" %>%
    get_samples_to_tags("TCGA_Subtype", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/samples_to_tags/tcga_study_samples_to_tags.feather"))

  .GlobalEnv$tcga_subtype_samples_to_tags <- "TCGA_Subtype" %>%
    get_samples_to_tags("TCGA_Study", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/samples_to_tags/tcga_subtype_samples_to_tags.feather"))

  .GlobalEnv$immune_subtype_samples_to_tags <- "Immune_Subtype" %>%
    get_samples_to_tags("TCGA_Study", "TCGA_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/samples_to_tags/immune_subtype_samples_to_tags.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tcga_study_samples_to_tags, pos = ".GlobalEnv")
  rm(tcga_subtype_samples_to_tags, pos = ".GlobalEnv")
  rm(immune_subtype_samples_to_tags, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
