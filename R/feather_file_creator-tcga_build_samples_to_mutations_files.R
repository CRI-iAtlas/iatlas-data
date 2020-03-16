tcga_build_samples_to_mutations_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_samples_to_mutations_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_samples_to_mutations <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get samples_to_mutations")), fill = TRUE)

    cat_samples_to_mutations_status("Get the initial values from the samples_to_mutations table.")
    samples_to_mutations <- current_pool %>% dplyr::tbl("samples_to_mutations")

    cat_samples_to_mutations_status("Get the mutation relationships from the mutations table.")
    samples_to_mutations <- samples_to_mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("mutations") %>%
        dplyr::select(mutation_id = id, gene_id, mutation_code_id, mutation_type_id),
      by = "mutation_id"
    )

    cat_samples_to_mutations_status("Get the gene entrez from the genes table.")
    samples_to_mutations <- samples_to_mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("genes") %>%
        dplyr::select(gene_id = id, entrez),
      by = "gene_id"
    )

    cat_samples_to_mutations_status("Get the mutation code from the mutation_codes table.")
    samples_to_mutations <- samples_to_mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("mutation_codes") %>%
        dplyr::select(mutation_code_id = id, mutation_code = code),
      by = "mutation_code_id"
    )

    cat_samples_to_mutations_status("Get the mutation type from the mutation_types table.")
    samples_to_mutations <- samples_to_mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("mutation_types") %>%
        dplyr::select(mutation_type_id = id, mutation_type = name),
      by = "mutation_type_id"
    )

    cat_samples_to_mutations_status("Get the samples from the samples table.")
    samples_to_mutations <- samples_to_mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("samples") %>%
        dplyr::select(sample_id = id, sample = name),
      by = "sample_id"
    )

    cat_samples_to_mutations_status("Clean up the data set.")
    samples_to_mutations <- samples_to_mutations %>%
      dplyr::distinct(entrez, sample, mutation_code, mutation_type, status) %>%
      dplyr::arrange(entrez, sample, mutation_type, mutation_code)

    cat_samples_to_mutations_status("Execute the query and return a tibble.")
    samples_to_mutations <- samples_to_mutations %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(samples_to_mutations)
  }

  all_samples_to_mutations <- get_samples_to_mutations()
  all_samples_to_mutations <- all_samples_to_mutations %>%
    split(rep(1:3, each = ceiling(length(all_samples_to_mutations)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$samples_to_mutations_01 <- all_samples_to_mutations %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/samples_to_mutations/samples_to_mutations_01.feather"))

  .GlobalEnv$samples_to_mutations_02 <- all_samples_to_mutations %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/samples_to_mutations/samples_to_mutations_02.feather"))

  .GlobalEnv$samples_to_mutations_03 <- all_samples_to_mutations %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/samples_to_mutations/samples_to_mutations_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(samples_to_mutations_01, pos = ".GlobalEnv")
  rm(samples_to_mutations_02, pos = ".GlobalEnv")
  rm(samples_to_mutations_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
