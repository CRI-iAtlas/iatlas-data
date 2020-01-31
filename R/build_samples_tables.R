# build_samples_tables ---------------------------------------------------
build_samples_tables <- function(feather_file_folder) {

  # reset tables ---------------------------------------------------
  iatlas.data::drop_table("features_to_samples")
  iatlas.data::drop_table("genes_to_samples")
  iatlas.data::drop_table("patients_to_slides")
  iatlas.data::drop_table("samples_to_tags")
  iatlas.data::drop_table("samples")
  iatlas.data::drop_table("patients")

  # read genes table, rna-sequence-expression and raw samples ---------------------------------------------------
  genes <- iatlas.data::read_table("genes") %>% dplyr::as_tibble() %>% dplyr::select(id, hgnc)
  rna_seq_expr_matrix <- load_rna_seq_expr(feather_file_folder, genes)
  all_samples <- load_all_samples(feather_file_folder)

  build_patients_table(feather_file_folder, all_samples, rna_seq_expr_matrix)

  # read-back patients and add patient_id to samples ---------------------------------------------------
  cat(crayon::magenta("Add patient_id to samples data."), fill = TRUE)
  patients <- iatlas.data::read_table("patients") %>% dplyr::select(patient_id = id, sample = barcode)
  all_samples_with_patient_ids <- all_samples %>% dplyr::left_join(patients, by = "sample")
  cat(crayon::blue("Added patient_id to samples data."), fill = TRUE)

  build_samples_table(all_samples_with_patient_ids)

  # read-back sample db data ---------------------------------------------------
  cat(crayon::magenta("Read the samples table to get samples data with ids."), fill = TRUE)
  samples <- iatlas.data::read_table("samples") %>% dplyr::as_tibble()
  cat(crayon::blue("Done reading the samples table."), fill = TRUE, sep = " ")

  build_samples_to_tags_table(all_samples_with_patient_ids, samples)
  build_features_to_samples_table(all_samples_with_patient_ids, samples)
  build_genes_to_samples_table(all_samples_with_patient_ids, rna_seq_expr_matrix, genes, samples)

  build_slides_table(feather_file_folder, patients)
}
