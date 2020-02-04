get_slides_by_study <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_slides_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_slides <- function(study, exclude01, exclude02) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get slides by `", study, "`")), fill = TRUE)

    cat_slides_status("Get the initial values from the slides table.")
    slides <- current_pool %>% dplyr::tbl("slides")

    cat_slides_status("Get patient ids related to the slides.")
    slides <- slides %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("patients_to_slides"),
      by = c("id" = "slide_id")
    )

    cat_slides_status("Get sample ids related to the patients.")
    slides <- slides %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("samples") %>%
        dplyr::select(sample_id = id, patient_id),
      by = "patient_id"
    )

    cat_slides_status("Get tag ids related to the samples.")
    slides <- slides %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("samples_to_tags"),
      by = c("id" = "sample_id")
    )

    cat_slides_status("Get the tag names for the samples by tag id.")
    slides <- slides %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, tag_name = name),
      by = c("tag_id" = "id")
    )

    cat_slides_status("Get tag ids related to the tags :)")
    slides <- slides %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags_to_tags"),
      by = "tag_id"
    )

    cat_slides_status("Get the related tag names for the samples by related tag id.")
    slides <- slides %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, related_tag_name = name),
      by = c("related_tag_id" = "id")
    )

    cat_slides_status("Filter the data set to tags related to the passed study.")
    slides <- slides %>% dplyr::filter(
      tag_name == study | related_tag_name == study |
        (tag_name != exclude01 & related_tag_name == exclude01 &
           tag_name != exclude02 & related_tag_name == exclude02)
    )

    cat_slides_status("Clean up the data set.")
    slides <- slides %>%
      dplyr::distinct(name, description) %>%
      dplyr::arrange(name)

    cat_slides_status("Execute the query and return a tibble.")
    slides <- slides %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(slides)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_slides <- "TCGA_Study" %>%
    get_slides("TCGA_Subtype", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/slides/tcga_study_slides.feather"))

  .GlobalEnv$tcga_subtype_slides <- "TCGA_Subtype" %>%
    get_slides("TCGA_Study", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/slides/tcga_subtype_slides.feather"))

  .GlobalEnv$immune_subtype_slides <- "Immune_Subtype" %>%
    get_slides("TCGA_Study", "TCGA_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/slides/immune_subtype_slides.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tcga_study_slides, pos = ".GlobalEnv")
  rm(tcga_subtype_slides, pos = ".GlobalEnv")
  rm(immune_subtype_slides, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
