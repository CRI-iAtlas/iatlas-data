get_genes_to_types <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_genes_to_types_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_data_frame <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get genes_to_types")), fill = TRUE)

    cat_genes_to_types_status("Get the initial values from the genes_to_types table.")
    genes_to_types <- current_pool %>% dplyr::tbl("genes_to_types")

    cat_genes_to_types_status("Get the gene types from the gene_types table.")
    genes_to_types <- genes_to_types %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("gene_types") %>%
        dplyr::select(type_id = id, gene_type = name),
      by = "type_id"
    )

    cat_genes_to_types_status("Get the genes from the genes table.")
    genes_to_types <- genes_to_types %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("genes") %>%
        dplyr::select(gene_id = id, entrez, hgnc),
      by = "gene_id"
    )

    cat_genes_to_types_status("Clean up the data set.")
    genes_to_types <- genes_to_types %>%
      dplyr::distinct(entrez, hgnc, gene_type) %>%
      dplyr::arrange(entrez, hgnc, gene_type)

    cat_genes_to_types_status("Execute the query and return a tibble.")
    genes_to_types <- genes_to_types %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(genes_to_types)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$genes_to_types <- get_data_frame() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_to_types/tcga_genes_to_types.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(genes_to_types, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
