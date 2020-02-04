get_gene_types <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_gene_types_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_type <- function(type) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get gene_type `", type, "`")), fill = TRUE)

    cat_gene_types_status("Get the initial values from the gene_types table.")
    gene_types <- current_pool %>% dplyr::tbl("gene_types")

    cat_gene_types_status("Limit to only the passed type.")
    gene_types <- gene_types %>% dplyr::filter(name == type)

    cat_gene_types_status("Clean up the data set.")
    gene_types <- gene_types %>%
      dplyr::distinct(name, display) %>%
      dplyr::filter(!is.na(name)) %>%
      dplyr::arrange(name)

    cat_gene_types_status("Execute the query and return a tibble.")
    gene_types <- gene_types %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(gene_types)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$driver_mutation <- "driver_mutation" %>%
    get_type %>%
    feather::write_feather(paste0(getwd(), "/feather_files/gene_types/driver_mutation_gene_type.feather"))

  .GlobalEnv$ecn <- "extra_cellular_network" %>%
    get_type %>%
    feather::write_feather(paste0(getwd(), "/feather_files/gene_types/ecn_gene_type.feather"))

  .GlobalEnv$immunomodulator <- "immunomodulator" %>%
    get_type %>%
    feather::write_feather(paste0(getwd(), "/feather_files/gene_types/immunomodulator_gene_type.feather"))

  .GlobalEnv$io_target <- "io_target" %>%
    get_type %>%
    feather::write_feather(paste0(getwd(), "/feather_files/gene_types/io_target_gene_type.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(driver_mutation, pos = ".GlobalEnv")
  rm(ecn, pos = ".GlobalEnv")
  rm(immunomodulator, pos = ".GlobalEnv")
  rm(io_target, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
