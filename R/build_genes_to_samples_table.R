build_genes_to_samples_table <- function() {

  # genes_to_samples import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for genes_to_samples."), fill = TRUE)
  genes_to_samples <- read_iatlas_data_file(
    get_feather_file_folder(),
    "relationships/genes_to_samples"
  ) %>%
    dplyr::distinct(entrez, hgnc, sample, rna_seq_expr) %>%
    dplyr::filter(!is.na(hgnc) & !is.na(sample)) %>%
    dplyr::arrange(entrez, hgnc, sample, rna_seq_expr)
  cat(crayon::blue("Imported feather files for genes_to_samples."), fill = TRUE)

  cat(crayon::magenta("Building genes_to_samples data.\n\t(These are some large datasets, please be patient as they are read and built.)"), fill = TRUE)


  # genes_to_samples data ---------------------------------------------------
  cat(crayon::magenta("Building genes_to_samples data.\n\t(These are some large datasets, please be patient as they are read and built.)"), fill = TRUE)
  # This should be joined by entrez.
  genes_to_samples <- genes_to_samples %>% dplyr::left_join(get_genes(), by = "hgnc")

  genes_to_samples <- genes_to_samples %>% dplyr::left_join(
    get_samples() %>% dplyr::select(sample_id = id, sample = name),
    by = "sample"
  )

  genes_to_samples <- genes_to_samples %>% dplyr::select(gene_id, sample_id, rna_seq_expr)
  cat(crayon::blue("Built genes_to_samples data."), fill = TRUE)
  cat_genes_to_samples_status("Built genes_to_samples data.")

  # genes_to_samples table ---------------------------------------------------
  cat(crayon::magenta("Building genes_to_samples table."), fill = TRUE)
  table_written <- genes_to_samples %>% iatlas.data::replace_table("genes_to_samples")
  cat(crayon::blue("Built genes_to_samples table."))

}
