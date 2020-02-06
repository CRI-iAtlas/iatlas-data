
build_patients_table <- function() {

  # patients import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for patients."), fill = TRUE)
  patients <- read_iatlas_data_file(get_feather_file_folder(), "patients")
  cat(crayon::blue("Imported feather files for patients."), fill = TRUE)

  # patients correct columns ---------------------------------------------------
  cat(crayon::magenta("Ensuring patients have all the correct columns."), fill = TRUE)
  patients <- patients %>%
    dplyr::bind_rows(dplyr::tibble(
      barcode = character(),
      age = integer(),
      ethnicity = character(),
      gender = character(),
      height = character(),
      race = character(),
      weight = numeric()
    )) %>%
    dplyr::distinct(barcode, age, ethnicity, gender, height, race, weight) %>%
    dplyr::filter(!is.na(barcode)) %>%
    dplyr::arrange(barcode)
  cat(crayon::blue("Ensured patients have all the correct columns."), fill = TRUE)

  # patients table ---------------------------------------------------
  cat(crayon::magenta("Building patients table."), fill = TRUE, sep = " ")
  table_written <- patients %>% iatlas.data::replace_table("patients")
  cat(crayon::blue("Built patients table. (", nrow(patients), "rows )"), fill = TRUE, sep = " ")
}
