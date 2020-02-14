build_genes_to_samples_table <- function() {

  # genes_to_samples import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for genes_to_samples."), fill = TRUE)
  genes_to_samples <- iatlas.data::read_iatlas_data_file(
    iatlas.data::get_feather_file_folder(),
    "relationships/genes_to_samples"
  )
  cat(crayon::blue("Imported feather files for genes_to_samples."), fill = TRUE)

  # genes_to_samples column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring genes_to_samples have all the correct columns and no dupes."), fill = TRUE)
  # TODO: This should be filtered by entrez not hgnc.
  genes_to_samples <- genes_to_samples %>%
    dplyr::bind_rows(dplyr::tibble(
      entrez = integer(),
      hgnc = character(),
      sample = character(),
      rna_seq_expr = numeric()
    )) %>%
    dplyr::distinct(entrez, hgnc, sample, rna_seq_expr) %>%
    dplyr::filter((!is.na(entrez) | !is.na(hgnc)) & !is.na(sample)) %>%
    iatlas.data::resolve_df_dupes(keys = c("hgnc", "sample")) %>%
    dplyr::select(entrez, hgnc, sample, rna_seq_expr) %>%
    dplyr::arrange(entrez, hgnc, sample)
  cat(crayon::blue("Ensured genes_to_samples have all the correct columns and no dupes."), fill = TRUE)

  # genes_to_samples data ---------------------------------------------------
  cat(crayon::magenta("Building genes_to_samples data.\n\t(These are some large datasets, please be patient as they are read and built.)"), fill = TRUE)
  # TODO: This should be joined by entrez.
  genes_to_samples <- genes_to_samples %>% dplyr::left_join(iatlas.data::get_genes(), by = "hgnc")

  genes_to_samples <- genes_to_samples %>% dplyr::left_join(
    iatlas.data::get_samples() %>% dplyr::select(sample_id = id, sample = name),
    by = "sample"
  )

  genes_to_samples <- genes_to_samples %>% dplyr::select(gene_id, sample_id, rna_seq_expr)
  cat(crayon::blue("Built genes_to_samples data."), fill = TRUE)

  # genes_to_samples table ---------------------------------------------------
  cat(crayon::magenta("Building genes_to_samples table."), fill = TRUE)
  table_written <- genes_to_samples %>% iatlas.data::replace_table("genes_to_samples")
  cat(crayon::blue("Built genes_to_samples table."), fill = TRUE)

}
