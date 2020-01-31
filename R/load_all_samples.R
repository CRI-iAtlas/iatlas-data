load_all_samples <- function(feather_file_folder) {
  cat(crayon::magenta("Importing feather files for samples and combining all the sample data."), fill = TRUE)
  on.exit(cat(crayon::blue("Imported feather files for samples and combined all the sample data."), fill = TRUE))
  feature_values_long <- read_iatlas_data_file(feather_file_folder, "SQLite_data/feature_values_long.feather")
  expr_matrix <- read_iatlas_data_file(feather_file_folder, "expr_matrix.feather") %>%
    dplyr::select(patient = ParticipantBarcode, barcode = Representative_Expression_Matrix_AliquotBarcode)

  dplyr::bind_rows(
      read_iatlas_data_file(feather_file_folder, "SQLite_data/driver_mutations*.feather"),
      read_iatlas_data_file(feather_file_folder, "SQLite_data/io_target_expr*.feather"),
      read_iatlas_data_file(feather_file_folder, "SQLite_data/immunomodulator_expr.feather")
    ) %>%
    dplyr::rename(rna_seq_expr = value) %>%
    dplyr::bind_rows(feature_values_long) %>%
    dplyr::arrange(sample) %>%
    dplyr::left_join(
      expr_matrix,
      by = c("sample" = "patient")
    )
}