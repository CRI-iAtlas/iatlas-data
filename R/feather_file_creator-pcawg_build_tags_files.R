pcawg_build_tags_files <- function() {

  cat_tags_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_tags <- function() {

    cat(crayon::magenta(paste0("Get PCAWG tags.")), fill = TRUE)

    cat_tags_status("Get initial data from Synapse.")
    samples <- dplyr::tibble(
      name = character(),
      characteristics = character(),
      display = character(),
      color = character()
    )

    return(tags)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$pcawg_tags <- get_tags() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/tags/pcawg_tags.feather"))

  # Log out of Synapse.
  iatlas.data::synapse_logout()

  ### Clean up ###
  # Data
  rm(pcawg_tags, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
