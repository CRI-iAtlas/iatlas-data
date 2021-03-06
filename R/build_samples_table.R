build_samples_table <- function(...) {

  # samples import ---------------------------------------------------
  cat(crayon::magenta("Importing sample files for samples"), fill = TRUE)
  all_samples <- synapse_read_all_feather_files("syn22125724")
  cat(crayon::blue("Imported sample files for samples"), fill = TRUE)

  # samples column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring samples have all the correct columns and no dupes."), fill = TRUE)
  samples <- all_samples %>%
    dplyr::bind_rows(dplyr::tibble(
      name = character(),
      patient_barcode = character()
    )) %>%
    dplyr::filter(!is.na(name)) %>%
    dplyr::distinct() %>%
    iatlas.data::resolve_df_dupes(keys = c("name")) %>%
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

  # datasets_to_samples column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring datasets_to_samples have all the correct columns and no dupes."), fill = TRUE)
  datasets_to_samples  <- all_samples %>%
    dplyr::bind_rows(dplyr::tibble(
      name = character(),
      dataset = character()
    )) %>%
    dplyr::select("sample" = "name", "dataset") %>%
    dplyr::filter(
      !is.na(sample),
      !is.na(dataset)
    ) %>%
    dplyr::distinct(sample, dataset) %>%
    iatlas.data::resolve_df_dupes(keys = c("sample", "dataset")) %>%
    dplyr::arrange(sample)

  cat(crayon::blue("Ensured datasets_to_samples all the correct columns and no dupes."), fill = TRUE)

  # datasets_to_samples data ---------------------------------------------------
  cat(crayon::magenta("Building datasets_to_samples data."), fill = TRUE)
  datasets_to_samples <- datasets_to_samples %>%
    dplyr::left_join(iatlas.data::get_datasets(), by = "dataset") %>%
    dplyr::left_join(iatlas.data::get_samples(), by = c("sample" = "name")) %>%
    dplyr::select("dataset_id", "sample_id" = "id")
  cat(crayon::blue("Built datasets_to_samples data."), fill = TRUE)

  # datasets_to_samples table ---------------------------------------------------
  cat(crayon::magenta("Building the datasets_to_samples table."), fill = TRUE)
  table_written <- datasets_to_samples %>% iatlas.data::replace_table("datasets_to_samples")
  cat(crayon::blue("Built the datasets_to_samples table. (", nrow(samples), "rows )"), fill = TRUE, sep = " ")

}
