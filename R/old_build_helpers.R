old_load_all_samples <- function(feather_file_folder) {
  cat(crayon::magenta("Importing feather files for samples and combining all the sample data."), fill = TRUE)
  on.exit(cat(crayon::blue("Imported feather files for samples and combined all the sample data."), fill = TRUE))
  feature_values_long <- iatlas.data::read_iatlas_data_file(feather_file_folder, "SQLite_data/feature_values_long.feather")
  expr_matrix <- iatlas.data::read_iatlas_data_file(feather_file_folder, "expr_matrix.feather") %>%
    dplyr::select(patient = ParticipantBarcode, barcode = Representative_Expression_Matrix_AliquotBarcode)

  dplyr::bind_rows(
    iatlas.data::read_iatlas_data_file(feather_file_folder, "SQLite_data/driver_mutations*.feather"),
    iatlas.data::read_iatlas_data_file(feather_file_folder, "SQLite_data/io_target_expr*.feather"),
    iatlas.data::read_iatlas_data_file(feather_file_folder, "SQLite_data/immunomodulator_expr.feather")
  ) %>%
    dplyr::rename(rna_seq_expr = value) %>%
    dplyr::bind_rows(feature_values_long) %>%
    dplyr::arrange(sample) %>%
    dplyr::left_join(
      expr_matrix,
      by = c("sample" = "patient")
    )
}

old_load_rna_seq_expr <- function(feather_file_folder, genes) {
  iatlas.data::timed(
    before_message = crayon::magenta("Importing HUGE RNA Seq Expr file.\n(This is VERY large and may take some time to open. Please be patient.)\n"),
    after_message = crayon::blue("Imported HUGE RNA Seq Expr file."),

    get_rna_seq_expr(feather_file_folder) %>%
      tidyr::separate(gene_id, c("hgnc", "entrez"), sep = "[|]") %>%
      dplyr::select(-c(entrez)) %>%
      dplyr::filter(hgnc != "?") %>%
      dplyr::filter(hgnc %in% genes[["hgnc"]])
  )
}

#' old_create_gene_expression_lookup
#'
#' @param gen_exp is the large, 1.8gigabyte TCGA feather-file loaded via feather::read_feather
#' @return lookup(), a function that takes (gene_id, sample_id) and returns the gene-expression or NULL if no match
old_create_gene_expression_lookup <- function (gene_exp) {
  gene_exp <- tibble::as_tibble(gene_exp)
  gene_map <- vector_to_env(purrr::map(gene_exp[[1]], function(f) strsplit(f, "\\|")[[1]][[1]]))
  sample_map <- vector_to_env(colnames(gene_exp))

  function(gene_id, sample_id) {
    if (
      iatlas.data::present(sample_id) &&
      iatlas.data::present(gene_id) &&
      iatlas.data::present(col_num <- sample_map[[sample_id]]) &&
      iatlas.data::present(row_num <- gene_map[[gene_id]])
    )
      return(gene_exp[[col_num]][[row_num]])
    return(NA)
  }
}

old_read_features <- function() result_cached("features", iatlas.data::read_table("features") %>% dplyr::as_tibble() %>% dplyr::select(feature_id = id, feature = name))
old_read_tags <- function() result_cached("tags", iatlas.data::read_table("tags") %>% dplyr::as_tibble() %>% dplyr::select(tag_id = id, tag = name))
old_read_genes <- function() result_cached("genes", iatlas.data::read_table("genes") %>% dplyr::as_tibble() %>% dplyr::select(gene_id = id, hgnc))
old_read_mutation_codes <- function() result_cached("mutation_codes", iatlas.data::read_table("mutation_codes") %>% dplyr::as_tibble() %>% dplyr::rename(mutation_code_id = id))
old_read_patients <- function() result_cached("patients", iatlas.data::read_table("patients") %>% dplyr::select(patient_id = id, barcode))
old_read_samples <- function() result_cached("samples", iatlas.data::read_table("samples") %>% dplyr::as_tibble() %>% dplyr::select(sample_id = id, sample = name))

old_get_rna_seq_expr_matrix <- function() result_cached("old_rna_seq_expr_matrix", old_load_rna_seq_expr(.GlobalEnv$feather_file_folder, old_read_genes()))
old_get_all_samples <- function() result_cached("all_samples", old_load_all_samples(.GlobalEnv$feather_file_folder))
old_get_all_samples_with_patient_ids <- function() result_cached("all_samples_with_patient_ids", old_get_all_samples() %>% dplyr::left_join(old_read_patients(), by = c("sample" = "barcode")))
