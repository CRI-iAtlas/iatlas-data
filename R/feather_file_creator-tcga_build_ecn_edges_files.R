tcga_build_ecn_edges_files <- function() {

  cat_ecn_edges_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_edges <- function(dataset) {

    cat(crayon::magenta(paste0("Get TCGA ", dataset," edges.")), fill = TRUE)
    edges <- dplyr::tibble()

    cat_ecn_edges_status("Get the initial values from Synapse.")
    if (dataset == "cytokine") {
      edges <- iatlas.data::get_tcga_cytokine_edges_cached()
    } else if (dataset == "cellimage") {
      edges <- iatlas.data::get_cellimage_edges_cached()
    }

    return(edges)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_cytokine_edges <- "cytokine" %>% get_edges() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/edges/tcga_cytokine_edges.feather"))

  .GlobalEnv$cellimage_edges <- "cellimage" %>% get_edges() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/edges/cellimage_edges.feather"))

  # Log out of Synapse.
  iatlas.data::synapse_logout()

  ### Clean up ###
  # Data
  rm(tcga_cytokine_edges, pos = ".GlobalEnv")
  rm(cellimage_edges, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
