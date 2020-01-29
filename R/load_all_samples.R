load_all_samples <- function(feather_file_folder) {
  cat(crayon::magenta("Importing feather files for samples and combining all the sample data."), fill = TRUE)
  on.exit(cat(crayon::blue("Imported feather files for samples and combined all the sample data."), fill = TRUE))
  feature_values_long <- read_iatlas_data_file(feather_file_folder,"SQLite_data/feature_values_long.feather")
  all_samples <- dplyr::bind_rows(
      read_iatlas_data_file(feather_file_folder,"SQLite_data/driver_mutations1.feather"),
      read_iatlas_data_file(feather_file_folder,"SQLite_data/driver_mutations2.feather"),
      read_iatlas_data_file(feather_file_folder,"SQLite_data/driver_mutations3.feather"),
      read_iatlas_data_file(feather_file_folder,"SQLite_data/driver_mutations4.feather"),
      read_iatlas_data_file(feather_file_folder,"SQLite_data/driver_mutations5.feather"),
      read_iatlas_data_file(feather_file_folder,"SQLite_data/io_target_expr1.feather"),
      read_iatlas_data_file(feather_file_folder,"SQLite_data/io_target_expr2.feather"),
      read_iatlas_data_file(feather_file_folder,"SQLite_data/io_target_expr3.feather"),
      read_iatlas_data_file(feather_file_folder,"SQLite_data/io_target_expr4.feather"),
      read_iatlas_data_file(feather_file_folder,"SQLite_data/immunomodulator_expr.feather")
    ) %>%
    dplyr::rename(rna_seq_expr = value) %>%
    dplyr::bind_rows(feature_values_long) %>%
    dplyr::arrange(sample)
}