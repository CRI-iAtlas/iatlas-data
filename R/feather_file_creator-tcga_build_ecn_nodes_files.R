tcga_build_ecn_nodes_files <- function() {

  cat_ecn_nodes_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_nodes <- function() {

    cat(crayon::magenta(paste0("Get TCGA nodes.")), fill = TRUE)
    cat_ecn_nodes_status("Get the initial values from Synapse.")

    cytokine_nodes <-
      iatlas.data::get_tcga_cytokine_nodes_cached() %>%
      dplyr::mutate("network" = "cytokine")

    cellimage_nodes <-
      iatlas.data::get_tcga_cellimage_nodes_cached() %>%
      dplyr::mutate("network" = "cellimage")

    nodes <-
      dplyr::bind_rows(cytokine_nodes, cellimage_nodes) %>%
      dplyr::mutate("dataset" = "TCGA")

    return(nodes)
  }

  # Setting these to the GlobalEnv just for development purposes.

  .GlobalEnv$tcga_nodes <- iatlas.data::synapse_store_feather_file(
    get_nodes(),
    "tcga_nodes.feather",
    "syn22126180"
  )

  # Log out of Synapse.
  iatlas.data::synapse_logout()

  ### Clean up ###
  # Data
  rm(tcga_nodes, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
