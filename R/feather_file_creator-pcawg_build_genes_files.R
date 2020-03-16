pcawg_build_genes_files <- function() {

  cat_genes_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_genes <- function(gene_type) {

    cat(crayon::magenta(paste0("Get pcawg genes")), fill = TRUE)


    cat_genes_status("Get the initial values from Synapse.")
    genes <- dplyr::tibble(
      entrez = integer(),
      hgnc = character(),
      description = character(),
      friendly_name = character(),
      io_landscape_name = character(),
      gene_family = character(),
      gene_function = character(),
      immune_checkpoint = character(),
      node_type = character(),
      pathway = character(),
      super_category = character(),
      therapy_type = character(),
      references = character()
    )

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
