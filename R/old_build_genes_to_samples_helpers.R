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

old_get_genes <- function() result_cached("genes", iatlas.data::read_table("genes") %>% dplyr::as_tibble() %>% dplyr::select(id, hgnc))
old_get_rna_seq_expr_matrix <- function() result_cached("rna_seq_expr_matrix", load_rna_seq_expr(.GlobalEnv$feather_file_folder, old_get_genes()))
old_get_all_samples <- function() result_cached("all_samples", old_load_all_samples(.GlobalEnv$feather_file_folder))
old_get_patients <- function() result_cached("patients", iatlas.data::read_table("patients") %>% dplyr::select(patient_id = id, sample = barcode))
old_get_all_samples_with_patient_ids <- function() result_cached("all_samples_with_patient_ids", old_get_all_samples() %>% dplyr::left_join(old_get_patients(), by = "sample"))
old_get_samples <- function() result_cached("samples", iatlas.data::read_table("samples") %>% dplyr::as_tibble())
