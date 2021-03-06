build_slides_table <- function(...) {

  # slides import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for slides."), fill = TRUE)
  slides <- synapse_read_all_feather_files("syn22140512")
  cat(crayon::blue("Imported feather files for slides."), fill = TRUE)

  # slides correct columns ---------------------------------------------------
  cat(crayon::magenta("Ensuring slides have all the correct columns and no dupes."), fill = TRUE)
  slides <- slides %>%
    dplyr::bind_rows(dplyr::tibble(
      name = character(),
      description = character(),
      patient_barcode = character()
    )) %>%
    dplyr::filter(!is.na(name)) %>%
    dplyr::distinct(name, .keep_all = TRUE) %>%
    iatlas.data::resolve_df_dupes(keys = c("name")) %>%
    dplyr::arrange(name)

  slides <- slides %>% dplyr::left_join(iatlas.data::get_patients(), by = c("patient_barcode" = "barcode"))

  slides <- slides %>% dplyr::select(name, description, patient_id)
  cat(crayon::blue("Ensured slides have all the correct columns and no dupes."), fill = TRUE)

  # slides table ---------------------------------------------------
  cat(crayon::magenta("Building slides table."), fill = TRUE)
  table_written <- slides %>% iatlas.data::replace_table("slides")
  cat(crayon::blue("Built the slides tables. (", nrow(slides), "rows )"), fill = TRUE, sep = " ")

}
