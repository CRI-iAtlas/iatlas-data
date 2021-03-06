build_genes_to_samples_table <- function(max_rows = NULL) {

  # genes_to_samples import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for genes_to_samples."), fill = TRUE)
  genes_to_samples <- synapse_read_all_feather_files("syn22125645")
  cat(crayon::blue("Imported feather files for genes_to_samples."), fill = TRUE)

  # genes_to_samples column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring genes_to_samples have all the correct columns and no dupes."), fill = TRUE)
  genes_to_samples <- genes_to_samples %>%
    dplyr::bind_rows(dplyr::tibble(
      entrez = integer(),
      sample = character(),
      rna_seq_expr = numeric()
    )) %>%
    dplyr::select(entrez, sample, rna_seq_expr) %>%
    dplyr::distinct() %>%
    tidyr::drop_na() %>%
    iatlas.data::resolve_df_dupes(keys = c("entrez", "sample")) %>%
    dplyr::arrange(entrez, sample)
  cat(crayon::blue("Ensured genes_to_samples have all the correct columns and no dupes."), fill = TRUE)

  # genes_to_samples data ---------------------------------------------------
  cat(crayon::magenta("Building genes_to_samples data.\n\t(These are some large datasets, please be patient as they are read and built.)"), fill = TRUE)
  # TODO: This should be joined by entrez.
  genes_to_samples <- genes_to_samples %>% dplyr::inner_join(iatlas.data::get_genes(), by = "entrez")

  genes_to_samples <- genes_to_samples %>% dplyr::inner_join(
    iatlas.data::get_samples() %>% dplyr::select(sample_id = id, sample = name),
    by = "sample"
  )

  genes_to_samples <- genes_to_samples %>% dplyr::select(gene_id, sample_id, rna_seq_expr)
  cat(crayon::blue("Built genes_to_samples data."), fill = TRUE)

  # genes_to_samples table ---------------------------------------------------
  cat(crayon::magenta("Building genes_to_samples table."), fill = TRUE)
  table_written <- genes_to_samples %>% iatlas.data::replace_table("genes_to_samples", max_rows = max_rows)
  cat(crayon::blue("Built genes_to_samples table. (", nrow(genes_to_samples), "rows )"), fill = TRUE)

}
