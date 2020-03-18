tcga_build_ecn_nodes_files <- function() {

  cat_ecn_nodes_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_nodes <- function(dataset) {

    cat(crayon::magenta(paste0("Get TCGA ", dataset," nodes.")), fill = TRUE)
    nodes <- dplyr::tibble()

    cat_ecn_nodes_status("Get the initial values from Synapse.")
    if (dataset == "cytokine") {
      nodes <- iatlas.data::get_tcga_cytokine_nodes_cached()
    } else if (dataset == "cellimage") {
      nodes <- iatlas.data::get_cellimage_nodes_cached()
    }

    return(nodes)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_cytokine_nodes <- "cytokine" %>% get_nodes() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/nodes/tcga_cytokine_nodes.feather"))

  .GlobalEnv$cellimage_nodes <- "cellimage" %>% get_nodes() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/nodes/cellimage_nodes.feather"))

  # Log out of Synapse.
  iatlas.data::synapse_logout()

  ### Clean up ###
  # Data
  # rm(tcga_cytokine_nodes, pos = ".GlobalEnv")
  # rm(cellimage_nodes, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
