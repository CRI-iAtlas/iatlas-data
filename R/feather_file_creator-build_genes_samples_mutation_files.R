build_genes_samples_mutations_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_genes_samples_mutations_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_genes_samples_mutations <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get genes_samples_mutations")), fill = TRUE)

    cat_genes_samples_mutations_status("Get the initial values from the genes_samples_mutations table.")
    genes_samples_mutations <- current_pool %>% dplyr::tbl("genes_samples_mutations")

    cat_genes_samples_mutations_status("Get the gene entrezs from the genes table.")
    genes_samples_mutations <- genes_samples_mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("genes") %>%
        dplyr::select(id, entrez),
      by = c("gene_id" = "id")
    )

    cat_genes_samples_mutations_status("Get the samples from the samples table.")
    genes_samples_mutations <- genes_samples_mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("samples") %>%
        dplyr::select(id, sample = name),
      by = c("sample_id" = "id")
    )

    cat_genes_samples_mutations_status("Get the mutation codes from the mutation_codes table.")
    genes_samples_mutations <- genes_samples_mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("mutation_codes") %>%
        dplyr::select(id, mutation_code = code),
      by = c("mutation_code_id" = "id")
    )

    cat_genes_samples_mutations_status("Clean up the data set.")
    genes_samples_mutations <- genes_samples_mutations %>%
      dplyr::distinct(entrez, sample, mutation_code, status) %>%
      dplyr::arrange(entrez, sample, mutation_code)

    cat_genes_samples_mutations_status("Execute the query and return a tibble.")
    genes_samples_mutations <- genes_samples_mutations %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(genes_samples_mutations)
  }

  all_genes_samples_mutations <- get_genes_samples_mutations()
  all_genes_samples_mutations <- all_genes_samples_mutations %>%
    split(rep(1:3, each = ceiling(length(all_genes_samples_mutations)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$genes_samples_mutations_01 <- all_genes_samples_mutations %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_samples_mutations/genes_samples_mutations_01.feather"))

  .GlobalEnv$genes_samples_mutations_02 <- all_genes_samples_mutations %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_samples_mutations/genes_samples_mutations_02.feather"))

  .GlobalEnv$genes_samples_mutations_03 <- all_genes_samples_mutations %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_samples_mutations/genes_samples_mutations_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(genes_samples_mutations_01, pos = ".GlobalEnv")
  rm(genes_samples_mutations_02, pos = ".GlobalEnv")
  rm(genes_samples_mutations_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
