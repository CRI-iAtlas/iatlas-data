get_genes_to_samples_by_study <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  get_genes_to_samples <- function(study) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    # Get the initial values from the genes_to_samples table.
    genes_to_samples <- current_pool %>% dplyr::tbl("genes_to_samples")

    # Get the tag ids related to the samples.
    genes_to_samples <- genes_to_samples %>% dplyr::right_join(
      current_pool %>% dplyr::tbl("samples_to_tags"),
      by = "sample_id"
    )

    # Get the tag names for the samples by tag id.
    genes_to_samples <- genes_to_samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, tag_name = name),
      by = c("tag_id" = "id")
    )

    # Get tag ids related to the tags :)
    genes_to_samples <- genes_to_samples %>% dplyr::right_join(
      current_pool %>% dplyr::tbl("tags_to_tags"),
      by = "tag_id"
    )

    # Get the related tag names for the samples by related tag id.
    genes_to_samples <- genes_to_samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, related_tag_name = name),
      by = c("related_tag_id" = "id")
    )

    # Filter the data set to tags related to the passed study.
    genes_to_samples <- genes_to_samples %>%
      dplyr::filter(tag_name == study | related_tag_name == study)

    # Get the gene entrezs and hgncs from the genes table.
    genes_to_samples <- genes_to_samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("genes") %>%
        dplyr::select(id, entrez, hgnc),
      by = c("gene_id" = "id")
    )

    # Get the samples from the samples table.
    genes_to_samples <- genes_to_samples %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("samples") %>%
        dplyr::select(id, sample = name),
      by = c("sample_id" = "id")
    )

    # Clean up the data set.
    genes_to_samples <- genes_to_samples %>%
      dplyr::distinct(entrez, hgnc, sample, rna_seq_expr, status) %>%
      dplyr::arrange(entrez, hgnc, sample)

    # Execute the query and return a tibble.
    genes_to_samples <- genes_to_samples %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(genes_to_samples)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_genes_to_samples <- "TCGA_Study" %>%
    get_genes_to_samples %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_to_samples/tcga_study_genes_to_samples.feather"))

  .GlobalEnv$tcga_subtype_genes_to_samples <- "TCGA_Subtype" %>%
    get_genes_to_samples %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_to_samples/tcga_subtype_genes_to_samples.feather"))

  .GlobalEnv$immune_subtype_genes_to_samples <- "Immune_Subtype" %>%
    get_genes_to_samples %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_to_samples/immune_subtype_genes_to_samples.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tcga_study_genes_to_samples, pos = ".GlobalEnv")
  rm(tcga_subtype_genes_to_samples, pos = ".GlobalEnv")
  rm(immune_subtype_genes_to_samples, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
