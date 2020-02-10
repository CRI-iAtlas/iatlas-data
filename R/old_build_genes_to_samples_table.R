old_build_genes_to_samples_table <- function() {
  rna_seq_expr_matrix <- old_get_rna_seq_expr_matrix()

  cat(crayon::magenta("Building genes_to_samples data.\n\t(These are some large datasets, please be patient as they are read and built.)"), fill = TRUE)

  genes_to_samples <- old_get_all_samples_with_patient_ids()

  cat_genes_to_samples_status <- function (message)
    cat(crayon::cyan(paste0(" - ", message, " (", nrow(genes_to_samples), ")\n")))

  cat_genes_to_samples_status("Removing records missing gene or sample")
  genes_to_samples <- genes_to_samples %>%
    dplyr::filter(!is.na(gene)) %>%
    dplyr::filter(!is.na(sample))

  cat_genes_to_samples_status("Removing duplicates, first pass.")
  genes_to_samples <- genes_to_samples %>%
    dplyr::distinct(sample, gene, status, rna_seq_expr, barcode, patient_id)

  cat_genes_to_samples_status("Separating the mutation code from the HUGO id.")
  genes_to_samples <- genes_to_samples %>%
    dplyr::mutate(
      code = ifelse(!is.na(gene), iatlas.data::get_mutation_code(gene), NA),
      hgnc = ifelse(!is.na(gene), iatlas.data::trim_hgnc(gene), NA)
    )

  cat_genes_to_samples_status("Getting the correct RNA Seq Expr value.")

  get_rna_seq_expr <- create_gene_expression_lookup(rna_seq_expr_matrix)

  get_rna_value_from_matrix <- function(hgnc, barcode, patient_id, matrix)
    if (present(patient_id)) get_rna_seq_expr(hgnc, barcode)
    else NA

  get_rna_value_from_matrix_v <- Vectorize(get_rna_value_from_matrix, vectorize.args = c("hgnc", "barcode", "patient_id"))

  genes_to_samples <- genes_to_samples %>%
    dplyr::mutate(rna_seq_expr = get_rna_value_from_matrix_v(hgnc, barcode, patient_id, rna_seq_expr_matrix))

  cat_genes_to_samples_status("Removing duplicates, second pass.")
  genes_to_samples <- genes_to_samples %>%
    dplyr::distinct(sample, hgnc, code, status, rna_seq_expr)

  cat_genes_to_samples_status("Joining gene_ids.")
  genes_to_samples <- genes_to_samples %>%
    dplyr::left_join(old_read_genes() %>% dplyr::rename(gene_id = id), by = "hgnc")

  cat_genes_to_samples_status("Joining mutation_code_ids.")
  mutation_codes <- iatlas.data::read_table("mutation_codes") %>% dplyr::as_tibble()
  genes_to_samples <- genes_to_samples %>%
    dplyr::left_join(mutation_codes %>% dplyr::rename(mutation_code_id = id), by = "code")

  # cat_genes_to_samples_status("Ensuring no duplicates.")
  genes_to_samples <- genes_to_samples %>% dplyr::select(sample, gene_id, mutation_code_id, status, rna_seq_expr)

  cat_genes_to_samples_status("Joining samples to get ids.")
  genes_to_samples <- genes_to_samples %>%
    dplyr::left_join(old_read_samples(), by = c("sample" = "name"))

  # cat_genes_to_samples_status("Ensuring no duplicates.")
  genes_to_samples <- genes_to_samples %>% dplyr::select(id, gene_id, mutation_code_id, status, rna_seq_expr)

  cat_genes_to_samples_status("Rename id to sample_id and arrange.")
  genes_to_samples <- genes_to_samples %>%
    dplyr::rename(sample_id = id) %>%
    dplyr::arrange(sample_id, gene_id, mutation_code_id, status, rna_seq_expr)

  genes_to_samples <- genes_to_samples %>%
    iatlas.data::resolve_df_dupes(keys = c("sample_id", "gene_id", "mutation_code_id"))
  cat_genes_to_samples_status("Built genes_to_samples data.")

  # genes_to_samples <- feather::read_feather("./genes_to_samples.feather")

  # genes_to_samples table ---------------------------------------------------
  genes_to_samples %>%
    dplyr::distinct(sample_id, gene_id, rna_seq_expr) %>%
    iatlas.data::replace_table("genes_to_samples")

  genes_to_samples %>%
    dplyr::filter(!is.na(mutation_code_id)) %>%
    dplyr::distinct(sample_id, gene_id, mutation_code_id, status) %>%
    iatlas.data::replace_table("genes_samples_mutations")

  cat(crayon::blue("Built genes_to_samples table."))

}
