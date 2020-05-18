pcawg_build_genes_files <- function() {

  cat_genes_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_genes <- function() {
    cat(crayon::magenta(paste0("Get PCAWG genes")), fill = TRUE)

    cat_genes_status("Get the inital values from Synapse.")
    genes <- iatlas.data::get_pcawg_rnaseq_cached() %>%
      dplyr::distinct(entrez, hgnc)

    cat_genes_status("Get the known gene resolutions.")
    known_gene_resolutions <- iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "known_gene_resolutions.feather")

    cat_genes_status("Replace any alias hgncs, with official hgncs.")
    genes <- iatlas.data::resolve_hgnc_conflicts(genes)

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
