build_patients_to_slides_table <- function() {
  cat(crayon::magenta("Building patients_to_slides data."), fill = TRUE)

  # Import feather files for patients_to_slides
  patients_to_slides <- read_iatlas_data_file(
    get_feather_file_folder(),
    "relationships/patients_to_slides"
  ) %>%
    dplyr::distinct(patient_id, slide_id) %>%
    dplyr::filter(!is.na(patient_id) & !is.na(slide_id)) %>%
    dplyr::arrange(patient_id, slide_id)

  # Import feather files for patients_to_slides
  patients_to_slides <- patients_to_slides %>% dplyr::left_join(
    iatlas.data::read_table("slides") %>%
      dplyr::select(slide_id = id, name),
    by = "slide_id"
  )

  patients_to_slides <- patients_to_slides %>% dplyr::left_join(get_patients(), by = "patient_id")

  # patients_to_slides table ---------------------------------------------------
  patients_to_slides %>% iatlas.data::replace_table("patients_to_slides")

  cat(crayon::blue("Built the patients_to_slides tables. (", nrow(patients_to_slides), " rows)"), fill = TRUE, sep = " ")
}
