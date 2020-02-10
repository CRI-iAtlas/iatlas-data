build_samples_table <- function() {

  # sample data ---------------------------------------------------
  cat(crayon::magenta("Building samples data."), fill = TRUE)
  samples <- get_all_samples() %>%
    dplyr::distinct(name, barcode = patient_barcode) %>%
    dplyr::filter(!is.na(name) & !is.na(barcode)) %>%
    dplyr::arrange(name)

  samples <- samples %>%
    dplyr::left_join(get_patients(), by = "barcode") %>%
    dplyr::select(name, patient_id)
  cat(crayon::blue("Built samples data."), fill = TRUE)

  # sample table ---------------------------------------------------
  cat(crayon::magenta("Building the samples table."), fill = TRUE)
  table_written <- samples %>% iatlas.data::replace_table("samples")
  cat(crayon::blue("Built the samples table. (", nrow(samples), "rows )"), fill = TRUE, sep = " ")

}
