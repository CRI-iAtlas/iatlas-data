pcawg_build_genes_to_samples_files <- function() {

  cat_genes_to_samples_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_genes_to_samples <- function() {

    cat(crayon::magenta(paste0("Get PCAWG genes_to_samples.")), fill = TRUE)

    cat_genes_to_samples_status("Get the initial values from the genes_to_samples table.")
    genes_to_samples <- iatlas.data::get_pcawg_rnaseq_cached()

    cat_genes_to_samples_status("Clean up the data set.")
    genes_to_samples <- genes_to_samples %>% dplyr::distinct(entrez, sample, rna_seq_expr)

    return(genes_to_samples)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$pcawg_genes_to_samples <- get_genes_to_samples() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/genes_to_samples/pcawg_genes_to_samples.feather"))

  # Log out of Synapse.
  iatlas.data::synapse_logout()

  ### Clean up ###
  # Data
  rm(pcawg_genes_to_samples, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
