build_slides_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_slides_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_slides <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get slides.")), fill = TRUE)

    cat_slides_status("Get the initial values from the slides table.")
    slides <- current_pool %>% dplyr::tbl("slides")

    cat_slides_status("Clean up the data set.")
    slides <- slides %>%
      dplyr::distinct(name, description) %>%
      dplyr::arrange(name)

    cat_slides_status("Execute the query and return a tibble.")
    slides <- slides %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(slides)
  }

  all_slides <- get_slides()
  all_slides <- all_slides %>% split(rep(1:3, each = ceiling(length(all_slides)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$slides_01 <- all_slides %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/slides/slides_01.feather"))

  .GlobalEnv$slides_02 <- all_slides %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/slides/slides_02.feather"))

  .GlobalEnv$slides_03 <- all_slides %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/slides/slides_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(slides_01, pos = ".GlobalEnv")
  rm(slides_02, pos = ".GlobalEnv")
  rm(slides_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
