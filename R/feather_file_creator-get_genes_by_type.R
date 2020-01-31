get_genes_by_type <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_genes_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_genes <- function(gene_type) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat_genes_status("Get the initial values from the genes table.")
    genes <- current_pool %>% dplyr::tbl("genes")

    cat_genes_status("Get all the gene type ids related to the genes in the table.")
    if (!is.na(gene_type)) {
      genes <- genes %>%
        dplyr::right_join(
          current_pool %>% dplyr::tbl("genes_to_types"),
          by = c("id" = "gene_id")
        )
    } else {
      genes <- genes %>%
        dplyr::left_join(
          current_pool %>% dplyr::tbl("genes_to_types"),
          by = c("id" = "gene_id")
        ) %>%
        dplyr::filter(is.na(type_id))
    }

    cat_genes_status("Get all the related gene types from the gene_types table.")
    genes <- genes %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("gene_types") %>%
        dplyr::select(id, type = name),
      by = c("type_id" = "id")
    )

    cat_genes_status("Filter the genese down to genes with only the passed gene type.")
    if (!is.na(gene_type)) {
      genes <- genes %>% dplyr::filter(type == gene_type)
    } else {
      genes <- genes %>% dplyr::filter(is.na(type))
    }

    cat_genes_status("Get all the related gene families from the gene_families table.")
    genes <- genes %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("gene_families") %>%
        dplyr::rename(gene_family = name),
      by = c("gene_family_id" = "id")
    )

    cat_genes_status("Get all the related gene funtions from the gene_functions table.")
    genes <- genes %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("gene_functions") %>%
        dplyr::rename(gene_function = name),
      by = c("gene_function_id" = "id")
    )

    cat_genes_status("Get all the related immune checkpoints from the immune_checkpoints table.")
    genes <- genes %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("immune_checkpoints") %>%
        dplyr::rename(immune_checkpoint = name),
      by = c("immune_checkpoint_id" = "id")
    )

    cat_genes_status("Get all the related pathways from the pathways table.")
    genes <- genes %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("pathways") %>%
        dplyr::rename(pathway = name),
      by = c("pathway_id" = "id")
    )

    cat_genes_status("Get all the related super categories from the super_categories table.")
    genes <- genes %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("super_categories") %>%
        dplyr::rename(super_category = name),
      by = c("super_cat_id" = "id")
    )

    cat_genes_status("Get all the related therapy types from the therapy_types table.")
    genes <- genes %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("therapy_types") %>%
        dplyr::rename(therapy_type = name),
      by = c("therapy_type_id" = "id")
    )

    cat_genes_status("Clean up the data set.")
    genes <- genes %>%
      dplyr::distinct(entrez, hgnc, description, friendly_name, io_landscape_name, gene_family, gene_function, immune_checkpoint, pathway, super_category, therapy_type, references) %>%
      dplyr::arrange(entrez, hgnc)

    cat_genes_status("Execute the query and return a tibble.")
    genes <- genes %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    cat_genes_status("Get the entrez.")
    gene_ids <- feather::read_feather(paste0(getwd(), "/feather_files/gene_ids.feather")) %>%
      dplyr::as_tibble()

    cat_genes_status("Add the entrez to the genes.")
    genes <- genes %>%
      dplyr::left_join(gene_ids, by = "hgnc") %>%
      tibble::add_column(entrez = NA %>% as.character, .before = "hgnc") %>%
      dplyr::mutate(entrez = ifelse(is.na(entrez.x), entrez.y, entrez.x)) %>%
      dplyr::select(-c(entrez.x, entrez.y))

    return(genes)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$driver_mutation_genes <- "driver_mutation" %>%
    get_genes %>%
    feather::write_feather(paste0(getwd(), "/feather_files/genes/driver_mutation_genes.feather"))

  .GlobalEnv$extra_cellular_network_genes <- "extra_cellular_network" %>%
    get_genes %>%
    feather::write_feather(paste0(getwd(), "/feather_files/genes/extra_cellular_network_genes.feather"))

  .GlobalEnv$immunomodulator_genes <- "immunomodulator" %>%
    get_genes %>%
    feather::write_feather(paste0(getwd(), "/feather_files/genes/immunomodulator_genes.feather"))

  .GlobalEnv$io_target_genes <- "io_target" %>%
    get_genes %>%
    feather::write_feather(paste0(getwd(), "/feather_files/genes/io_target_genes.feather"))

  # .GlobalEnv$other_genes <- NA %>%
  #   get_genes %>%
  #   feather::write_feather(paste0(getwd(), "/feather_files/genes/other_genes.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(driver_mutation_genes, pos = ".GlobalEnv")
  rm(extra_cellular_network_genes, pos = ".GlobalEnv")
  rm(immunomodulator_genes, pos = ".GlobalEnv")
  rm(io_target_genes, pos = ".GlobalEnv")
  # rm(other_genes, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
