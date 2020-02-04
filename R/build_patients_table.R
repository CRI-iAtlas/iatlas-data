
build_patients_table <- function() {

  # patients import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for patients."), fill = TRUE)
  patients <- read_iatlas_data_file(get_feather_file_folder(), "patients") %>%
    dplyr::distinct(barcode = patient_barcode, age, ethnicity, gender, race) %>%
    dplyr::filter(!is.na(barcode)) %>%
    dplyr::arrange(barcode)
  cat(crayon::blue("Imported feather files for patients."), fill = TRUE)

  # patients table ---------------------------------------------------
  cat(crayon::magenta("Building patients table."), fill = TRUE, sep = " ")
  patients %>% iatlas.data::replace_table("patients")
  cat(crayon::blue("Built patients table. (", nrow(patients), "rows )"), fill = TRUE, sep = " ")
}
