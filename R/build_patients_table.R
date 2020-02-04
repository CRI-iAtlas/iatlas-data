
build_patients_table <- function() {
  cat(crayon::magenta("Building patients data.)"), fill = TRUE)

  # Import feather files for samples.
  patients <- get_all_samples() %>%
    dplyr::distinct(barcode = patient_barcode, age, ethnicity, gender, race) %>%
    dplyr::arrange(barcode)

  # patients table ---------------------------------------------------
  cat(crayon::magenta("Building patients table."), fill = TRUE, sep = " ")
  patients %>% iatlas.data::replace_table("patients")
  cat(crayon::blue("Built patients table. (", nrow(patients), "rows )"), fill = TRUE, sep = " ")
}
