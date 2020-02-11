build_samples_table <- function() {

  # samples import ---------------------------------------------------
  cat(crayon::magenta("Importing sample files for samples"), fill = TRUE)
  samples <- iatlas.data::get_all_samples()
  cat(crayon::blue("Imported sample files for samples"), fill = TRUE)

  # samples column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring samples have all the correct columns and no dupes."), fill = TRUE)
  samples <- samples %>%
    dplyr::bind_rows(dplyr::tibble(
      name = character(),
      patient_barcode = character()
    )) %>%
    dplyr::distinct() %>%
    dplyr::filter(!is.na(name)) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Ensured samples have all the correct columns and no dupes."), fill = TRUE)

  # sample data ---------------------------------------------------
  cat(crayon::magenta("Building samples data."), fill = TRUE)
  samples <- samples %>%
    dplyr::left_join(
      iatlas.data::get_patients() %>%
        dplyr::select(patient_id, patient_barcode = barcode),
      by = "patient_barcode"
    ) %>%
    dplyr::select(name, patient_id)
  cat(crayon::blue("Built samples data."), fill = TRUE)

  # sample table ---------------------------------------------------
  cat(crayon::magenta("Building the samples table."), fill = TRUE)
  table_written <- samples %>% iatlas.data::replace_table("samples")
  cat(crayon::blue("Built the samples table. (", nrow(samples), "rows )"), fill = TRUE, sep = " ")

}
