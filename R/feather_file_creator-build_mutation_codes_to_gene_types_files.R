build_mutation_codes_to_gene_types_files <- function() {
  default_mutation_code <- "(NS)"
  default_gene_type <- "driver_mutation"

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

    mutation_codes_to_gene_types <- current_pool %>%
      dplyr::tbl("mutation_codes_to_gene_types")

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
      dplyr::filter(!is.na(gene_type) & !is.na(code))

    cat_mutation_codes_to_gene_types_status("Execute the query and return a tibble.")
    mutation_codes_to_gene_types <- mutation_codes_to_gene_types %>%
      dplyr::as_tibble() %>%
      dplyr::add_row(code = default_mutation_code, gene_type = default_gene_type) %>%
      dplyr::arrange(gene_type, code)

    pool::poolReturn(current_pool)

    return(mutation_codes_to_gene_types)
  }

  all_mutation_codes_to_gene_types <- get_codes_to_types()
  all_mutation_codes_to_gene_types <- all_mutation_codes_to_gene_types %>%
    split(rep(1:3, each = ceiling(length(all_mutation_codes_to_gene_types)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$mutation_codes_to_gene_types_01 <- all_mutation_codes_to_gene_types %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/mutation_codes_to_gene_types/mutation_codes_to_gene_types_01.feather"))

  .GlobalEnv$mutation_codes_to_gene_types_02 <- all_mutation_codes_to_gene_types %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/mutation_codes_to_gene_types/mutation_codes_to_gene_types_02.feather"))

  .GlobalEnv$mutation_codes_to_gene_types_03 <- all_mutation_codes_to_gene_types %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/mutation_codes_to_gene_types/mutation_codes_to_gene_types_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  # rm(mutation_codes_to_gene_types_01, pos = ".GlobalEnv")
  # rm(mutation_codes_to_gene_types_02, pos = ".GlobalEnv")
  # rm(mutation_codes_to_gene_types_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
