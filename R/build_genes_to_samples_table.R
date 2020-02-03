build_genes_to_samples_table <- function() {
  all_samples_with_patient_ids <- get_all_samples_with_patient_ids()
  rna_seq_expr_matrix <- get_rna_seq_expr_matrix()
  genes <- get_genes()
  samples <- get_samples()

  cat(crayon::magenta("Building genes_to_samples data.\n\t(These are some large datasets, please be patient as they are read and built.)"), fill = TRUE)

  .GlobalEnv$all_samples_with_patient_ids <- all_samples_with_patient_ids

  genes_to_samples <- all_samples_with_patient_ids

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

  .GlobalEnv$rna_seq_expr_matrix <- rna_seq_expr_matrix
  .GlobalEnv$genes_to_samples_with_hgnc <- genes_to_samples

  genes_to_samples <- genes_to_samples %>%
    dplyr::mutate(rna_seq_expr = get_rna_value_from_matrix_v(hgnc, barcode, patient_id, rna_seq_expr_matrix))

  cat_genes_to_samples_status("Removing duplicates, second pass.")
  genes_to_samples <- genes_to_samples %>%
    dplyr::distinct(sample, hgnc, code, status, rna_seq_expr)

  cat_genes_to_samples_status("Joining gene_ids.")
  genes_to_samples <- genes_to_samples %>%
    dplyr::left_join(genes %>% dplyr::rename(gene_id = id), by = "hgnc")

  .GlobalEnv$genes_to_sampleswith_gene_ids <- genes_to_samples

  cat_genes_to_samples_status("Joining mutation_code_ids.")
  mutation_codes <- iatlas.data::read_table("mutation_codes") %>% dplyr::as_tibble()
  genes_to_samples <- genes_to_samples %>%
    dplyr::left_join(mutation_codes %>% dplyr::rename(mutation_code_id = id), by = "code")

  cat_genes_to_samples_status("Ensuring no duplicates.")
  genes_to_samples <- genes_to_samples %>% dplyr::distinct(sample, gene_id, mutation_code_id, status, rna_seq_expr)

  cat_genes_to_samples_status("Joining samples to get ids.")
  genes_to_samples <- genes_to_samples %>%
    dplyr::left_join(samples, by = c("sample" = "name"))

  cat_genes_to_samples_status("Ensuring no duplicates.")
  genes_to_samples <- genes_to_samples %>% dplyr::distinct(id, gene_id, mutation_code_id, status, rna_seq_expr)

  cat_genes_to_samples_status("Rename id to sample_id and arrange.")
  genes_to_samples <- genes_to_samples %>%
    dplyr::rename(sample_id = id) %>%
    dplyr::arrange(sample_id, gene_id, mutation_code_id, status, rna_seq_expr)

  genes_to_samples <- genes_to_samples %>% resolve_genes_to_samples_dupes()
  cat_genes_to_samples_status("Built genes_to_samples data.")

  genes_to_samples %>% validate_control_data("genes_to_samples")
  # genes_to_samples table ---------------------------------------------------
  cat(crayon::magenta("Building genes_to_samples table.\n\t(There are", nrow(genes_to_samples), "rows to write, this may take a little while.)"), fill = TRUE)
  genes_to_samples %>% iatlas.data::replace_table("genes_to_samples")
  cat(crayon::blue("Built genes_to_samples table."))

}