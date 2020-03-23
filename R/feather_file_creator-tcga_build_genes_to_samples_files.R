tcga_build_genes_to_samples_files <- function() {

  cat_genes_to_samples_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  feather_file_folder <- paste0(getwd(), "/feather_files")

  get_genes_to_samples <- function() {

    cat(crayon::magenta(paste0("Get TCGA genes_to_samples.")), fill = TRUE)

    # immunomodulator_expr ---------------------------------------------------
    cat_genes_to_samples_status("Get the immunomodulators expr values from feather files.")
    immunomodulator_expr <- iatlas.data::get_tcga_immunomodulator_exprs_cached() %>%
      dplyr::distinct(entrez, sample, rna_seq_expr)

    # io_target_expr ---------------------------------------------------
    cat_genes_to_samples_status("Get the io target expr values from feather files.")
    io_target_expr <- iatlas.data::get_tcga_io_target_exprs_cached() %>%
      dplyr::distinct(entrez, sample, rna_seq_expr)

    # Bind expression genes ---------------------------------------------------
    cat_genes_to_samples_status("Bind expression genes.")
    expr_genes <- immunomodulator_expr %>%
      dplyr::bind_rows(io_target_expr) %>%
      dplyr::filter(!is.na(entrez) & !is.na(sample)) %>%
      dplyr::distinct(entrez, sample, rna_seq_expr)

    # driver_mutations ---------------------------------------------------
    cat_genes_to_samples_status("Get the driver_mutation values from feather files.")
    driver_mutations <- iatlas.data::get_tcga_driver_mutations_cached() %>%
      dplyr::filter(!is.na(entrez) & !is.na(sample)) %>%
      dplyr::distinct(entrez, sample)

    # Bind genes ---------------------------------------------------
    cat_genes_to_samples_status("Bind all genes.")
    genes_to_samples <- expr_genes %>% dplyr::bind_rows(driver_mutations)

    genes <- genes_to_samples %>% dplyr::distinct(entrez)

    # correct rna_seq_expr ---------------------------------------------------
    rna_seq_expr_matrix <- iatlas.data::get_rna_seq_expr_matrix(genes)
    cat_genes_to_samples_status("Get the correct RNA Seq Expr value.")
    get_rna_seq_expr <- iatlas.data::create_gene_expression_lookup(rna_seq_expr_matrix)

    expr_matrix <- feather::read_feather("feather_files/expr_matrix.feather") %>%
      dplyr::distinct(sample = ParticipantBarcode, barcode = Representative_Expression_Matrix_AliquotBarcode)

    genes_to_samples <- genes_to_samples %>% dplyr::left_join(expr_matrix, by = "sample")

    get_rna_value_from_matrix <- function(entrez, barcode) {
      return(ifelse(iatlas.data::present(barcode), get_rna_seq_expr(entrez, barcode), NA))
    }

    get_rna_value_from_matrix_v <- Vectorize(get_rna_value_from_matrix, vectorize.args = c("entrez", "barcode"))

    genes_to_samples <- genes_to_samples %>%
      dplyr::mutate(rna_seq_expr = get_rna_value_from_matrix_v(entrez, barcode))

    return(genes_to_samples)
  }

  # Create feather files ---------------------------------------------------
  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_genes_to_samples <- get_genes_to_samples() %>%
    feather::write_feather(paste0(feather_file_folder, "/relationships/genes_to_samples/tcga_genes_to_samples.feather"))

  # Clean up ---------------------------------------------------
  # Log out of Synapse.
  iatlas.data::synapse_logout()

  # Data
  rm(tcga_genes_to_samples, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
