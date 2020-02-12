old_build_slides_table <- function() {
  cat(crayon::magenta("Building slides data."), fill = TRUE)
  slides <- iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "SQLite_data/til_image_links.feather") %>%
    dplyr::rename(name = link) %>%
    dplyr::mutate(name = ifelse(!is.na(name), stringi::stri_extract_first(name, regex = "[\\w]{4}-[\\w]{2}-[\\w]{4}-[\\w]{3}-[\\d]{2}-[\\w]{3}"), NA)) %>%
    dplyr::distinct(name, sample)

  slides <- slides %>% dplyr::left_join(
    iatlas.data::old_read_samples() %>%
      dplyr::select(sample = name, patient_id),
    by = "sample"
  ) %>%
    dplyr::filter(!is.na(patient_id)) %>%
    dplyr::distinct(name, patient_id) %>%
    dplyr::arrange(name, patient_id)
  cat(crayon::blue("Built the slides data. (", nrow(slides), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building slides table."), fill = TRUE)
  table_written <- slides %>% iatlas.data::replace_table("slides")
  cat(crayon::blue("Built the slides table. (", nrow(slides), "rows )"), fill = TRUE, sep = " ")
}
