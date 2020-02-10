build_genes_samples_mutations_table <- function() {

  # genes_samples_mutations import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for genes_samples_mutations."), fill = TRUE)
  # TODO: This should be filtered by entrez not hgnc.
  genes_samples_mutations <- iatlas.data::read_iatlas_data_file(
    get_feather_file_folder(),
    "relationships/genes_samples_mutations"
  ) %>%
    dplyr::distinct(entrez, hgnc, sample, mutation_code, status) %>%
    dplyr::filter(!is.na(hgnc) & !is.na(sample)) %>%
    dplyr::arrange(entrez, hgnc, sample, mutation_code, status)
  cat(crayon::blue("Imported feather files for genes_samples_mutations."), fill = TRUE)

  # genes_samples_mutations data ---------------------------------------------------
  cat(crayon::magenta("Building genes_samples_mutations data.\n\t(These are some large datasets, please be patient as they are read and built.)"), fill = TRUE)
  # TODO: This should be joined by entrez.
  genes_samples_mutations <- genes_samples_mutations %>% dplyr::left_join(iatlas.data::get_genes(), by = "hgnc")

  genes_samples_mutations <- genes_samples_mutations %>% dplyr::left_join(
    iatlas.data::get_samples() %>% dplyr::select(sample_id = id, sample = name),
    by = "sample"
  )

  genes_samples_mutations <- genes_samples_mutations %>% dplyr::left_join(
    iatlas.data::read_table("mutation_codes") %>%
      dplyr::as_tibble() %>%
      dplyr::select(mutation_code_id = id, mutation_code = code),
    by = "mutation_code"
  )

  genes_samples_mutations <- genes_samples_mutations %>% dplyr::distinct(gene_id, sample_id, mutation_code_id, status)
  cat(crayon::blue("Built genes_samples_mutations data."), fill = TRUE)

  # genes_samples_mutations table ---------------------------------------------------
  cat(crayon::magenta("Building genes_samples_mutations table."), fill = TRUE)
  table_written <- genes_samples_mutations %>% iatlas.data::replace_table("genes_samples_mutations")
  cat(crayon::blue("Built genes_samples_mutations table."))

}
