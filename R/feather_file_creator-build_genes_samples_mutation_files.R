build_genes_samples_mutations_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_genes_samples_mutations_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_genes_samples_mutations <- function(study, exclude01, exclude02) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get genes_samples_mutations by `", study, "`")), fill = TRUE)

    cat_genes_samples_mutations_status("Get the initial values from the genes_samples_mutations table.")
    genes_samples_mutations <- current_pool %>% dplyr::tbl("genes_samples_mutations")

    cat_genes_samples_mutations_status("Get the tag ids related to the samples.")
    genes_samples_mutations <- genes_samples_mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("samples_to_tags"),
      by = "sample_id"
    )

    cat_genes_samples_mutations_status("Get the tag names for the samples by tag id.")
    genes_samples_mutations <- genes_samples_mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, tag_name = name),
      by = c("tag_id" = "id")
    )

    cat_genes_samples_mutations_status("Get tag ids related to the tags :)")
    genes_samples_mutations <- genes_samples_mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags_to_tags"),
      by = "tag_id"
    )

    cat_genes_samples_mutations_status("Get the related tag names for the samples by related tag id.")
    genes_samples_mutations <- genes_samples_mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, related_tag_name = name),
      by = c("related_tag_id" = "id")
    )

    cat_genes_samples_mutations_status("Filter the data set to tags related to the passed study.")
    genes_samples_mutations <- genes_samples_mutations %>%
      dplyr::filter(
        tag_name == study | related_tag_name == study |
          (tag_name != exclude01 & related_tag_name == exclude01 &
             tag_name != exclude02 & related_tag_name == exclude02)
      )

    cat_genes_samples_mutations_status("Get the gene entrezs and hgncs from the genes table.")
    genes_samples_mutations <- genes_samples_mutations %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("genes") %>%
        dplyr::select(id, entrez, hgnc),
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
      dplyr::distinct(entrez, hgnc, sample, mutation_code, status) %>%
      dplyr::arrange(entrez, hgnc, mutation_code, sample)

    cat_genes_samples_mutations_status("Execute the query and return a tibble.")
    genes_samples_mutations <- genes_samples_mutations %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(genes_samples_mutations)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_genes_samples_mutations <- "TCGA_Study" %>%
    get_genes_samples_mutations("TCGA_Subtype", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_samples_mutations/tcga_study_genes_samples_mutations.feather"))

  .GlobalEnv$tcga_subtype_genes_samples_mutations <- "TCGA_Subtype" %>%
    get_genes_samples_mutations("TCGA_Study", "Immune_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_samples_mutations/tcga_subtype_genes_samples_mutations.feather"))

  .GlobalEnv$immune_subtype_genes_samples_mutations <- "Immune_Subtype" %>%
    get_genes_samples_mutations("TCGA_Study", "TCGA_Subtype") %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_samples_mutations/immune_subtype_genes_samples_mutations.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tcga_study_genes_samples_mutations, pos = ".GlobalEnv")
  rm(tcga_subtype_genes_samples_mutations, pos = ".GlobalEnv")
  rm(immune_subtype_genes_samples_mutations, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
