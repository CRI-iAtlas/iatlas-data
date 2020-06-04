pcawg_build_tags_files <- function() {

  cat_tags_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_tags <- function() {

    cat(crayon::magenta(paste0("Get PCAWG tags.")), fill = TRUE)

    cat_tags_status("Get initial values from Synapse.")
    tags <- iatlas.data::get_pcawg_tag_values_cached() %>%
      dplyr::select(name = tag) %>%
      dplyr::mutate(display = NA %>% as.character()) %>%
      dplyr::add_row(name = "PCAWG", display = "PCAWG") %>%
      dplyr::add_row(name = "PCAWG_Study", display = "PCAWG Study") %>%
      dplyr::add_row(name = "Immune_Subtype", display = "Immune Subtype")

    cat_tags_status("Clean up the data set.")
    tags <- tags %>%
      dplyr::distinct(name, display) %>%
      dplyr::arrange(name)

    return(tags)
  }

  # Setting these to the GlobalEnv just for development purposes.

  .GlobalEnv$pcawg_samples_to_tags <- iatlas.data::synapse_store_feather_file(
    get_tags(),
    "pcawg_tags.feather",
    "syn22125978"
  )

  ### Clean up ###
  # Data
  rm(pcawg_tags, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
