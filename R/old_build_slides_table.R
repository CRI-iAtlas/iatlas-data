old_build_slides_table <- function() {
  cat(crayon::magenta("Building slides & patients_to_slides data."), fill = TRUE)

  slides <- iatlas.data::read_iatlas_data_file(get_feather_file_folder(), "SQLite_data/til_image_links.feather") %>%
    dplyr::rename(name = link) %>%
    dplyr::mutate(name = ifelse(!is.na(name), stringi::stri_extract_first(name, regex = "[\\w]{4}-[\\w]{2}-[\\w]{4}-[\\w]{3}-[\\d]{2}-[\\w]{3}"), NA)) %>%
    dplyr::distinct(name, .keep_all = TRUE)

  slides %>% dplyr::distinct(name) %>% iatlas.data::replace_table("slides")

  patients_to_slides <- slides %>%
    dplyr::left_join(
      iatlas.data::read_table("slides") %>%
        dplyr::select(slide_id = id, name),
      by = "name"
    )
  patients_to_slides <- patients_to_slides %>%
    dplyr::left_join(old_get_patients(), by = "sample") %>%
    dplyr::filter(!is.na(patient_id)) %>%
    dplyr::distinct(patient_id, slide_id) %>%
    dplyr::arrange(patient_id, slide_id)

  # patients_to_slides table ---------------------------------------------------
  patients_to_slides %>% iatlas.data::replace_table("patients_to_slides")

  cat(crayon::blue("Built the slides & patients_to_slides tables. (", nrow(slides), "rows & ", nrow(patients_to_slides), " rows)"), fill = TRUE, sep = " ")
}
