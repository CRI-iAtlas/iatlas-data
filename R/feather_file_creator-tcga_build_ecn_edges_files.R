tcga_build_ecn_edges_files <- function() {

  cat_ecn_edges_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_edges <- function() {

    cat(crayon::magenta(paste0("Get TCGA edges.")), fill = TRUE)

    cytokine_edges <-
      iatlas.data::get_tcga_cytokine_edges_cached() %>%
      dplyr::mutate("network" = "cytokine")

    cellimage_edges <-
      iatlas.data::get_tcga_cellimage_edges_cached() %>%
      dplyr::mutate("network" = "cellimage")

    nodes <-
      dplyr::bind_rows(cytokine_edges, cellimage_edges) %>%
      dplyr::mutate("dataset" = "TCGA")

    return(nodes)
  }

  .GlobalEnv$tcga_edges <- iatlas.data::synapse_store_feather_file(
    get_edges(),
    "tcga_edges.feather",
    "syn22126181"
  )

  # Log out of Synapse.
  iatlas.data::synapse_logout()

  ### Clean up ###
  # Data
  rm(tcga_edges, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
