build_samples_to_tags_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_samples_to_tags_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_samples_to_tags <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get samples_to_tags.")), fill = TRUE)

    cat_samples_to_tags_status("Get the initial values from the samples_to_tags table.")
    samples_to_tags <- current_pool %>% dplyr::tbl("samples_to_tags")

    cat_samples_to_tags_status("Get the tag names for the samples by tag id.")
    samples_to_tags <- samples_to_tags %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, tag = name),
      by = c("tag_id" = "id")
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

  all_samples_to_tags <- get_samples_to_tags()
  all_samples_to_tags <- all_samples_to_tags %>%
    split(rep(1:3, each = ceiling(length(all_samples_to_tags)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$samples_to_tags_01 <- all_samples_to_tags %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/samples_to_tags/samples_to_tags_01.feather"))

  .GlobalEnv$samples_to_tags_02 <- all_samples_to_tags %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/samples_to_tags/samples_to_tags_02.feather"))

  .GlobalEnv$samples_to_tags_03 <- all_samples_to_tags %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/samples_to_tags/samples_to_tags_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(samples_to_tags_01, pos = ".GlobalEnv")
  rm(samples_to_tags_02, pos = ".GlobalEnv")
  rm(samples_to_tags_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
