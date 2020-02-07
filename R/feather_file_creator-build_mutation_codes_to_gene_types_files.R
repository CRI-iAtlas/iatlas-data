build_mutation_codes_to_gene_types_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_mutation_codes_to_gene_types_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_codes_to_types <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get mutation_codes_to_gene_types")), fill = TRUE)

    cat_mutation_codes_to_gene_types_status("Get the initial values from the mutation_codes_to_gene_types table.")
    mutation_codes_to_gene_types <- current_pool %>% dplyr::tbl("mutation_codes_to_gene_types")

    cat_mutation_codes_to_gene_types_status("Get the gene types from the gene_types table.")
    mutation_codes_to_gene_types <- mutation_codes_to_gene_types %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("gene_types") %>%
        dplyr::select(type_id = id, gene_type = name),
      by = "type_id"
    )

    cat_mutation_codes_to_gene_types_status("Get the mutation codes from the mutation_codes table.")
    mutation_codes_to_gene_types <- mutation_codes_to_gene_types %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("mutation_codes") %>%
        dplyr::select(mutation_code_id = id, code),
      by = "mutation_code_id"
    )

    cat_mutation_codes_to_gene_types_status("Clean up the data set.")
    mutation_codes_to_gene_types <- mutation_codes_to_gene_types %>%
      dplyr::distinct(gene_type, code) %>%
      dplyr::filter(!is.na(gene_type) & !is.na(code)) %>%
      dplyr::arrange(gene_type, code)

    cat_mutation_codes_to_gene_types_status("Execute the query and return a tibble.")
    mutation_codes_to_gene_types <- mutation_codes_to_gene_types %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(mutation_codes_to_gene_types)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$mutation_codes_to_gene_types <- get_codes_to_types() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/mutation_codes_to_gene_types/tcga_mutation_codes_to_gene_types.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(mutation_codes_to_gene_types, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
