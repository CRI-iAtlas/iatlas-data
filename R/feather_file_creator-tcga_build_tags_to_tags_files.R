tcga_build_tags_to_tags_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_tags_to_tags_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_tags_to_tags <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get tags_to_tags.")), fill = TRUE)

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

    cat_tags_to_tags_status("Clean up the data set.")
    tags_to_tags <- tags_to_tags %>%
      dplyr::distinct(tag, related_tag) %>%
      dplyr::arrange(tag, related_tag)

    cat_tags_to_tags_status("Execute the query and return a tibble.")
    tags_to_tags <- tags_to_tags %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(tags_to_tags)
  }

  all_tags_to_tags <- get_tags_to_tags()
  all_tags_to_tags <- all_tags_to_tags %>% split(rep(1:3, each = ceiling(length(all_tags_to_tags)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tags_to_tags_01 <- all_tags_to_tags %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/tags_to_tags/tags_to_tags_01.feather"))

  .GlobalEnv$tags_to_tags_02 <- all_tags_to_tags %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/tags_to_tags/tags_to_tags_02.feather"))

  .GlobalEnv$tags_to_tags_03 <- all_tags_to_tags %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/tags_to_tags/tags_to_tags_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tags_to_tags_01, pos = ".GlobalEnv")
  rm(tags_to_tags_02, pos = ".GlobalEnv")
  rm(tags_to_tags_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
