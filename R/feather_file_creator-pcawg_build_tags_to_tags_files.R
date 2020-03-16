pcawg_build_tags_to_tags_files <- function() {

  cat_tags_to_tags_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_tags_to_tags <- function() {

    cat(crayon::magenta(paste0("Get pcawg tags_to_tags.")), fill = TRUE)

    cat_tags_to_tags_status("Build tags_to_tags. data.")
    tags_to_tags <- dplyr::tibble(tag = "PCAWG_Study", related_tag = "PCAWG")

    return(tags_to_tags)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$pcawg_tags_to_tags <- get_tags_to_tags() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/tags_to_tags/pcawg_tags_to_tags"))

  ### Clean up ###
  # Data
  rm(pcawg_tags_to_tags, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
