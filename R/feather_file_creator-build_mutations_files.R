build_mutations_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_mutations_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_mutations <- function() {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get mutations")), fill = TRUE)

    cat_mutations_status("Get the initial values from the mutations table.")
    mutations <- current_pool %>% dplyr::tbl("mutations")

    cat_mutations_status("Get all the mutation codes related to the mutation_code_ids in the table.")
    mutations <- mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("mutation_codes") %>%
        dplyr::select(mutation_code_id = id, code),
      by = "mutation_code_id"
    )

    cat_mutations_status("Get all the mutation types related to the mutation_type_ids in the table.")
    mutations <- mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("mutation_types") %>%
        dplyr::select(mutation_type_id = id, type = name),
      by = "mutation_type_id"
    )

    cat_mutations_status("Get all the genes related to the gene_ids in the table.")
    mutations <- mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("genes") %>%
        dplyr::select(gene_id = id, entrez),
      by = "gene_id"
    )

    cat_mutations_status("Clean up the data set.")
    mutations <- mutations %>%
      dplyr::distinct(entrez, code, type) %>%
      dplyr::arrange(entrez, type, code)

    cat_mutations_status("Execute the query and return a tibble.")
    mutations <- mutations %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(mutations)
  }

  all_mutations <- get_mutations()
  all_mutations <- all_mutations %>% split(rep(1:3, each = ceiling(length(all_mutations)/2.5)))

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$mutations_01 <- all_mutations %>% .[[1]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/mutations/mutations_01.feather"))

  .GlobalEnv$mutations_02 <- all_mutations %>% .[[2]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/mutations/mutations_02.feather"))

  .GlobalEnv$mutations_03 <- all_mutations %>% .[[3]] %>%
    feather::write_feather(paste0(getwd(), "/feather_files/mutations/mutations_03.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(mutations_01, pos = ".GlobalEnv")
  rm(mutations_02, pos = ".GlobalEnv")
  rm(mutations_03, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
