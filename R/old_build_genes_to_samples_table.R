old_build_genes_to_samples_table <- function() {
  default_mutation_code <- "(NS)"

  rna_seq_expr_matrix <- old_get_rna_seq_expr_matrix()

  cat(crayon::magenta("Building genes_to_samples data.\n\t(These are some large datasets, please be patient as they are read and built.)"), fill = TRUE)

  genes_to_samples <- old_get_all_samples_with_patient_ids()

  cat_genes_to_samples_status <- function(message)
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

  get_rna_seq_expr <- iatlas.data::old_create_gene_expression_lookup(rna_seq_expr_matrix)

  get_rna_value_from_matrix <- function(hgnc, barcode, patient_id, matrix)
    if (iatlas.data::present(patient_id)) get_rna_seq_expr(hgnc, barcode)
    else NA

  get_rna_value_from_matrix_v <- Vectorize(get_rna_value_from_matrix, vectorize.args = c("hgnc", "barcode", "patient_id"))

  genes_to_samples <- genes_to_samples %>%
    dplyr::mutate(rna_seq_expr = get_rna_value_from_matrix_v(hgnc, barcode, patient_id, rna_seq_expr_matrix))

  cat_genes_to_samples_status("Removing duplicates, second pass.")
  genes_to_samples <- genes_to_samples %>%
    dplyr::distinct(sample, hgnc, code, status, rna_seq_expr) %>%
    dplyr::mutate(code = ifelse(is.na(code), default_mutation_code, code))

  cat_genes_to_samples_status("Joining gene_ids.")
  genes_to_samples <- genes_to_samples %>%
    dplyr::left_join(old_read_genes(), by = "hgnc")

  cat_genes_to_samples_status("Joining mutation_code_ids.")
  genes_to_samples <- genes_to_samples %>% dplyr::left_join(old_read_mutation_codes(), by = "code")

  cat_genes_to_samples_status("Building mutations data.")
  mutations <- genes_to_samples %>%
    dplyr::distinct(gene_id, mutation_code_id) %>%
    dplyr::filter(!is.na(mutation_code_id)) %>%
    dplyr::mutate(mutation_type_id = 1) %>%
    dplyr::arrange(mutation_type_id, gene_id, mutation_code_id)
  cat(crayon::blue("Built mutations data. (", nrow(mutations), "rows )"), fill = TRUE)

  cat_genes_to_samples_status("Building mutations table.")
  table_written <- mutations %>% iatlas.data::replace_table("mutations")
  cat(crayon::blue("Built mutations table. (", nrow(mutations), "rows )"), fill = TRUE, sep = " ")

  cat_genes_to_samples_status("Limit the columns.")
  genes_to_samples <- genes_to_samples %>% dplyr::select(sample, gene_id, mutation_code_id, status, rna_seq_expr)

  cat_genes_to_samples_status("Joining samples to get ids.")
  genes_to_samples <- genes_to_samples %>%
    dplyr::left_join(old_read_samples(), by = "sample")

  cat_genes_to_samples_status("Limit the columns.")
  genes_to_samples <- genes_to_samples %>% dplyr::select(sample_id, gene_id, mutation_code_id, status, rna_seq_expr)

  cat_genes_to_samples_status("Arrange the data nicely.")
  genes_to_samples <- genes_to_samples %>%
    dplyr::arrange(sample_id, gene_id, mutation_code_id, status, rna_seq_expr)

  genes_to_samples <- genes_to_samples %>%
    iatlas.data::resolve_df_dupes(keys = c("sample_id", "gene_id", "mutation_code_id"))
  cat(crayon::blue("Built genes_to_samples data."), fill = TRUE)

  # samples_to_mutations data ---------------------------------------------------
  cat(crayon::magenta("Building samples_to_mutations data."), fill = TRUE)
  samples_to_mutations <- genes_to_samples %>% dplyr::left_join(
      iatlas.data::read_table("mutations") %>%
        dplyr::as_tibble() %>%
        dplyr::select(mutation_id = id, gene_id, mutation_code_id),
      by = c("gene_id", "mutation_code_id")
  )
  samples_to_mutations <- samples_to_mutations %>%
    dplyr::distinct(sample_id, mutation_id, status) %>%
    dplyr::arrange(sample_id, mutation_id)
  cat(crayon::blue("Built samples_to_mutations data. (", nrow(samples_to_mutations), "rows )"), fill = TRUE)

  # samples_to_mutations table ---------------------------------------------------
  cat(crayon::magenta("Building samples_to_mutations table."), fill = TRUE)
  samples_to_mutations %>% iatlas.data::replace_table("samples_to_mutations")
  cat(crayon::blue("Built samples_to_mutations table. (", nrow(samples_to_mutations), "rows )"), fill = TRUE)

  # genes_to_samples table ---------------------------------------------------
  genes_to_samples <- genes_to_samples %>%
    dplyr::distinct(sample_id, gene_id, rna_seq_expr)
  genes_to_samples %>%
    iatlas.data::replace_table("genes_to_samples")

  cat(crayon::blue("Built genes_to_samples table. (", nrow(genes_to_samples), "rows )"))

}
