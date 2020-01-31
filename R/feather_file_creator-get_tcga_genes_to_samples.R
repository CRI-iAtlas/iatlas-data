get_tcga_genes_to_samples <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  get_genes_to_samples <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    genes_to_samples <- current_pool %>%
      dplyr::tbl("genes_to_samples") %>%
      dplyr::left_join(
        current_pool %>%
          dplyr::tbl("genes") %>%
          dplyr::select(id, hgnc),
        by = c("gene_id" = "id")
      ) %>%
      dplyr::left_join(
        current_pool %>%
          dplyr::tbl("samples") %>%
          dplyr::select(id, name) %>%
          dplyr::rename_at("name", ~("sample")),
        by = c("sample_id" = "id")
      ) %>%
      dplyr::distinct(hgnc, sample, rna_seq_expr, status) %>%
      dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(genes_to_samples)
  }

  # Setting this to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_genes_to_samples <- get_genes_to_samples() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_to_samples/tcga_genes_to_samples.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tcga_genes_to_samples, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
