tcga_build_genes_to_samples_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_genes_to_samples_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_genes_to_samples <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get genes_to_samples.")), fill = TRUE)

    cat_genes_to_samples_status("Get the initial values from the genes_to_samples table.")
    genes_to_samples <- current_pool %>% dplyr::tbl("genes_to_samples")

    cat_genes_to_samples_status("Get the gene entrezs from the genes table.")
    genes_to_samples <- genes_to_samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("genes") %>%
        dplyr::select(gene_id = id, entrez),
      by = "gene_id"
    )

    cat_genes_to_samples_status("Get the samples from the samples table.")
    genes_to_samples <- genes_to_samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("samples") %>%
        dplyr::select(sample_id = id, sample = name),
      by = "sample_id"
    )

    cat_genes_to_samples_status("Clean up the data set.")
    genes_to_samples <- genes_to_samples %>%
      dplyr::distinct(entrez, sample, rna_seq_expr) %>%
      dplyr::arrange(entrez, sample)

    cat_genes_to_samples_status("Execute the query and return a tibble.")
    genes_to_samples <- genes_to_samples %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(genes_to_samples)
  }

  all_genes_to_samples <- get_genes_to_samples()
  all_genes_to_samples <- all_genes_to_samples %>%
    split(rep(1:3, each = ceiling(length(all_genes_to_samples)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$genes_to_samples_01 <- all_genes_to_samples %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_to_samples/genes_to_samples_01.feather"))

  .GlobalEnv$genes_to_samples_02 <- all_genes_to_samples %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_to_samples/genes_to_samples_02.feather"))

  .GlobalEnv$genes_to_samples_03 <- all_genes_to_samples %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_to_samples/genes_to_samples_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(genes_to_samples_01, pos = ".GlobalEnv")
  rm(genes_to_samples_02, pos = ".GlobalEnv")
  rm(genes_to_samples_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
