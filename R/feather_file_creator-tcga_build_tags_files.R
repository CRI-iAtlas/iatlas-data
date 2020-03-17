tcga_build_tags_files <- function() {
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

    cat_tags_status("Ensure the TCGA tag exists.")
    tags <- tags %>% dplyr::add_row(name = "TCGA", display = "TCGA")

    cat_tags_status("Clean up the data set.")
    tags <- tags %>%
      dplyr::distinct(name, characteristics, display, color) %>%
      dplyr::arrange(name)

    pool::poolReturn(current_pool)

    return(tags)
  }

  all_tags <- get_tags()
  all_tags <- all_tags %>% split(rep(1:3, each = ceiling(length(all_tags)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tags_01 <- all_tags %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/tags/tags_01.feather"))

  .GlobalEnv$tags_02 <- all_tags %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/tags/tags_02.feather"))

  .GlobalEnv$tags_03 <- all_tags %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/tags/tags_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tags_01, pos = ".GlobalEnv")
  rm(tags_02, pos = ".GlobalEnv")
  rm(tags_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
