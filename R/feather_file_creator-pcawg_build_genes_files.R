pcawg_build_genes_files <- function() {

  cat_genes_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_genes <- function(gene_type) {

    cat(crayon::magenta(paste0("Get PCAWG genes")), fill = TRUE)

    # master_gene_ids ---------------------------------------------------
    cat_genes_status("Get master gene ids (write a feather file).")
    master_gene_ids <- iatlas.data::get_master_gene_ids_cached()

    cat_genes_status("Get the inital values from Synapse.")
    genes <- iatlas.data::get_pcawg_rnaseq_cached() %>% dplyr::distinct(entrez, hgnc)

    cat_genes_status("Ensure hgnc.")
    genes <- genes %>% dplyr::mutate(hgnc = ifelse(entrez %in% master_gene_ids$entrez, NA, hgnc))

    cat_genes_status("Clean up the data set.")
    genes <- genes %>% dplyr::distinct(entrez, hgnc)

    return(genes)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$pcawg_genes <- get_genes() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/genes/pcawg_genes.feather"))

  # Log out of Synapse.
  iatlas.data::synapse_logout()

  ### Clean up ###
  # Data
  rm(pcawg_genes, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
