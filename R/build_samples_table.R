build_samples_table <- function() {

  # sample data ---------------------------------------------------
  cat(crayon::magenta("Building samples data."), fill = TRUE)
  samples <- get_all_samples() %>%
    dplyr::distinct(name = sample, barcode = patient_barcode)

  samples <- samples %>%
    dplyr::left_join(get_patients(), by = "barcode") %>%
    dply::select(name, patient_id)
  cat(crayon::blue("Built samples data."), fill = TRUE)

  # sample table ---------------------------------------------------
  cat(crayon::magenta("Building the samples table."), fill = TRUE)
  samples %>% iatlas.data::replace_table("samples")
  cat(crayon::blue("Built the samples table. (", nrow(samples), "rows )"), fill = TRUE, sep = " ")

}
