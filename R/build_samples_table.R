build_samples_table <- function(all_samples_with_patient_ids) {

  cat(crayon::magenta("Building samples data."), fill = TRUE)
  samples <- all_samples_with_patient_ids %>%
    dplyr::distinct(name = sample, patient_id) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Built samples data."), fill = TRUE)

  # sample table ---------------------------------------------------
  cat(crayon::magenta("Building the samples table."), fill = TRUE)
  samples %>% iatlas.data::replace_table("samples")
  cat(crayon::blue("Built the samples table. (", nrow(samples), "rows )"), fill = TRUE, sep = " ")

}