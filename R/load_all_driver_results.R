load_all_driver_results <- function(feather_file_folder) {

  cat(crayon::magenta("Importing feather files for results."), fill = TRUE)
  driver_results1 <- read_iatlas_data_file(feather_file_folder, "SQLite_data/driver_results1.feather")
  driver_results2 <- read_iatlas_data_file(feather_file_folder, "SQLite_data/driver_results2.feather")
  cat(crayon::blue("Imported feather files for results."), fill = TRUE)

  cat(crayon::magenta("Bind driver_results data frames."), fill = TRUE)
  on.exit(cat(crayon::blue("Bound driver_results data frames."), fill = TRUE))

  dplyr::bind_rows(driver_results1, driver_results2) %>% dplyr::as_tibble()
}