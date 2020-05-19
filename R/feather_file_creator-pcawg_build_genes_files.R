pcawg_build_genes_files <- function() {

  cat_genes_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_genes <- function() {
    cat(crayon::magenta(paste0("Get PCAWG genes")), fill = TRUE)

    cat_genes_status("Import gene_ids.")
    gene_ids <- iatlas.data::get_gene_ids() %>% dplyr::filter(!is.na(hgnc))

    cat_genes_status("Get the inital values from Synapse.")
    genes <- iatlas.data::get_pcawg_rnaseq_cached() %>%
      dplyr::distinct(entrez, hgnc)

    cat_genes_status("Add the entrez to the genes.")
    genes <- genes %>% dplyr::left_join(gene_ids %>% dplyr::rename(real_entrez = entrez), by = "hgnc") %>%
      dplyr::mutate(entrez = ifelse(is.na(entrez), real_entrez, entrez)) %>%
      dplyr::select(-real_entrez)

    cat_genes_status("Ensure the correct hgnc.")
    genes <- genes %>% dplyr::left_join(gene_ids %>% dplyr::rename(official = hgnc), by = "entrez") %>%
      dplyr::mutate(hgnc = ifelse(!is.na(official), official, hgnc)) %>%
      dplyr::select(-official)

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
