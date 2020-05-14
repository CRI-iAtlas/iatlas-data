pcawg_build_tags_to_tags_files <- function() {

  cat_tags_to_tags_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_tags_to_tags <- function() {

    cat(crayon::magenta(paste0("Get pcawg tags_to_tags.")), fill = TRUE)

    cat_tags_to_tags_status("Get PCAWG tags from Synapse.")
    tags <- get_pcawg_tags_from_synapse() %>%
      dplyr::select(immune_subtype = subtype, pcawg_study = dcc_project_code)

    cat_tags_to_tags_status("Build tags_to_tags data.")
    tags_to_tags <- dplyr::tibble(tag = "PCAWG_Study", related_tag = "PCAWG") %>%
      dplyr::add_row(tag = "Immune_Subtype", related_tag = "PCAWG")
    tags_to_tags <- tags %>% dplyr::distinct(tag = immune_subtype) %>% dplyr::mutate(related_tag = "Immune_Subtype") %>% dplyr::bind_rows(tags_to_tags)
    tags_to_tags <- tags %>% dplyr::distinct(tag = pcawg_study) %>% dplyr::mutate(related_tag = "PCAWG_Study") %>% dplyr::bind_rows(tags_to_tags)

    return(tags_to_tags)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$pcawg_tags_to_tags <- get_tags_to_tags() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/tags_to_tags/pcawg_tags_to_tags.feather"))

  ### Clean up ###
  # Data
  rm(pcawg_tags_to_tags, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
