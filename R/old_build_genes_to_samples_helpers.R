old_get_result_cache <- function () {
  if (!present(.GlobalEnv$result_cache))
    .GlobalEnv$result_cache <- new.env()
  .GlobalEnv$result_cache
}

old_result_cached <- function (key, value) {
  result_cache <- old_get_result_cache()
  if (present(result_cache[[key]])) result_cache[[key]]
  else result_cache[[key]] <- value
}

old_reset_results_cache <- function () {
  if (present(.GlobalEnv$result_cache)) {
    rm(result_cache, pos = .GlobalEnv)
  }
  gc()
}

old_load_all_samples <- function(feather_file_folder) {
  cat(crayon::magenta("Importing feather files for samples and combining all the sample data."), fill = TRUE)
  on.exit(cat(crayon::blue("Imported feather files for samples and combined all the sample data."), fill = TRUE))
  feature_values_long <- iatlas.data::read_iatlas_data_file(feather_file_folder, "SQLite_data/feature_values_long.feather")
  expr_matrix <- iatlas.data::read_iatlas_data_file(feather_file_folder, "expr_matrix.feather") %>%
    dplyr::select(patient = ParticipantBarcode, barcode = Representative_Expression_Matrix_AliquotBarcode)

  dplyr::bind_rows(
    iatlas.data::read_iatlas_data_file(feather_file_folder, "SQLite_data/driver_mutations*.feather"),
    iatlas.data::read_iatlas_data_file(feather_file_folder, "SQLite_data/io_target_expr*.feather"),
    iatlas.data::read_iatlas_data_file(feather_file_folder, "SQLite_data/immunomodulator_expr.feather")
  ) %>%
    dplyr::rename(rna_seq_expr = value) %>%
    dplyr::bind_rows(feature_values_long) %>%
    dplyr::arrange(sample) %>%
    dplyr::left_join(
      expr_matrix,
      by = c("sample" = "patient")
    )
}

old_set_feather_file_folder <- function(feather_file_folder) .GlobalEnv$feather_file_folder <- feather_file_folder
old_get_feather_file_folder <- function() .GlobalEnv$feather_file_folder

old_get_genes <- function() old_result_cached("genes", iatlas.data::read_table("genes") %>% dplyr::as_tibble() %>% dplyr::select(id, hgnc))
old_get_rna_seq_expr_matrix <- function() old_result_cached("rna_seq_expr_matrix", load_rna_seq_expr(.GlobalEnv$feather_file_folder, old_get_genes()))
old_get_all_samples <- function() old_result_cached("all_samples", old_load_all_samples(.GlobalEnv$feather_file_folder))
old_get_patients <- function() old_result_cached("patients", iatlas.data::read_table("patients") %>% dplyr::select(patient_id = id, sample = barcode))
old_get_all_samples_with_patient_ids <- function() old_result_cached("all_samples_with_patient_ids", old_get_all_samples() %>% dplyr::left_join(old_get_patients(), by = "sample"))
old_get_samples <- function() old_result_cached("samples", iatlas.data::read_table("samples") %>% dplyr::as_tibble())
