tcga_build_genes_to_types_files <- function() {

  cat_genes_to_types_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  feather_file_folder <- paste0(getwd(), "/feather_files")

  get_genes_to_types <- function() {

    cat(crayon::magenta(paste0("Get TCGA genes_to_types")), fill = TRUE)

    # immunomodulator_expr ---------------------------------------------------
    cat_genes_to_types_status("Get the immunomodulators expr values from feather files.")
    immunomodulator_expr <- iatlas.data::get_tcga_immunomodulator_exprs_cached() %>%
      dplyr::distinct(entrez) %>%
      dplyr::mutate(gene_type = "immunomodulator")

    # immunomodulators ---------------------------------------------------
    cat_genes_to_types_status("Get the immunomodulators values from feather files.")
    immunomodulators <- iatlas.data::get_tcga_immunomodulator_genes_cached() %>%
      dplyr::distinct(entrez) %>%
      dplyr::mutate(gene_type = "immunomodulator")

    # io_target_expr ---------------------------------------------------
    cat_genes_to_types_status("Get the io target expr values from feather files.")
    io_target_expr <- iatlas.data::get_tcga_io_target_exprs_cached() %>%
      dplyr::distinct(entrez) %>%
      dplyr::mutate(gene_type = "io_target")

    # io_targets ---------------------------------------------------
    cat_genes_to_types_status("Get the io targets values from feather files.")
    io_targets <- iatlas.data::get_tcga_io_target_genes_cached() %>%
      dplyr::distinct(entrez) %>%
      dplyr::mutate(gene_type = "io_target")

    # ecn genes ---------------------------------------------------
    cat_genes_to_types_status("Import extra cellular network (ecn) feather files for genes")
    ecn_genes <- iatlas.data::get_tcga_cytokine_nodes_cached() %>%
      dplyr::filter(!is.na(entrez)) %>%
      dplyr::distinct(entrez) %>%
      dplyr::mutate(gene_type = "extra_cellular_network")

    # genes_to_types data ---------------------------------------------------
    genes_to_types <- immunomodulator_expr %>%
      dplyr::bind_rows(immunomodulators, io_target_expr, io_targets, ecn_genes) %>%
      dplyr::distinct(entrez, gene_type) %>%
      dplyr::arrange(entrez, gene_type)

    return(genes_to_types)
  }

  # Create feather files ---------------------------------------------------
  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_genes_to_types <- get_genes_to_types() %>%
    feather::write_feather(paste0(feather_file_folder, "/relationships/genes_to_types/tcga_genes_to_types.feather"))

  # Clean up ---------------------------------------------------
  # Log out of Synapse.
  iatlas.data::synapse_logout()

  # Data
  rm(tcga_genes_to_types, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
