build_patients_to_slides_table <- function() {
  cat(crayon::magenta("Building patients_to_slides data."), fill = TRUE)

  # patients_to_slides import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for patients_to_slides."), fill = TRUE)
  patients_to_slides <- iatlas.data::read_iatlas_data_file(
    get_feather_file_folder(),
    "relationships/patients_to_slides"
  ) %>%
    dplyr::distinct(barcode, slide) %>%
    dplyr::filter(!is.na(barcode) & !is.na(slide)) %>%
    dplyr::arrange(barcode, slide)
  cat(crayon::blue("Imported feather files for patients_to_slides."), fill = TRUE)

  # patients_to_slides data ---------------------------------------------------
  cat(crayon::magenta("Building patients_to_slides data."), fill = TRUE)
  patients_to_slides <- patients_to_slides %>% dplyr::left_join(
    iatlas.data::read_table("slides") %>%
      dplyr::select(slide_id = id, slide = name),
    by = "slide"
  )

  patients_to_slides <- patients_to_slides %>%
    dplyr::left_join(get_patients(), by = "barcode")

  # .GlobalEnv$p_2_s <- cbind(patients_to_slides)

  patients_to_slides <- patients_to_slides %>% dplyr::select(patient_id, slide_id)
  cat(crayon::blue("Build patients_to_slides data."), fill = TRUE)

  # patients_to_slides table ---------------------------------------------------
  cat(crayon::magenta("Building patients_to_slides table."), fill = TRUE)
  table_written <- patients_to_slides %>% iatlas.data::replace_table("patients_to_slides")
  cat(crayon::blue("Built the patients_to_slides tables. (", nrow(patients_to_slides), " rows)"), fill = TRUE, sep = " ")

}
