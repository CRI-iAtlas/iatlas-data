build_tags_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_tags_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_tags <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get tags.")), fill = TRUE)

    cat_tags_status("Get initial data from the tags table.")
    tags <- current_pool %>% dplyr::tbl("tags")

    cat_tags_status("Clean up the data set.")
    tags <- tags %>%
      dplyr::filter(!is.na(name)) %>%
      dplyr::distinct(name, characteristics, display, color) %>%
      dplyr::arrange(name)

    cat_tags_status("Execute the query and return a tibble.")
    tags <- tags %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(tags)
  }

  .GlobalEnv$tcga_tags <- get_tags() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/tags/tcga_tags.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tcga_tags, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
