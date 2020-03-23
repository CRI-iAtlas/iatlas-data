tcga_build_genes_files <- function() {

  cat_genes_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  feather_file_folder <- paste0(getwd(), "/feather_files")

  cat(crayon::magenta(paste0("Get TCGA genes")), fill = TRUE)

  # human_gene_ids ---------------------------------------------------
  cat_genes_status("Get human gene ids from Synapse and write a feather file.")
  human_gene_ids <- iatlas.data::get_human_gene_ids_cached()

  # immunomodulator_expr ---------------------------------------------------
  cat_genes_status("Get the immunomodulators expr values from feather files.")
  immunomodulator_expr <- iatlas.data::get_tcga_immunomodulator_exprs_cached() %>%
    dplyr::distinct(entrez)

  # io_target_expr ---------------------------------------------------
  cat_genes_status("Get the io target expr values from feather files.")
  io_target_expr <- iatlas.data::get_tcga_io_target_exprs_cached() %>%
    dplyr::distinct(entrez)

  # Bind expression genes ---------------------------------------------------
  cat_genes_status("Bind expression genes.")
  expr_genes <- immunomodulator_expr %>%
    dplyr::bind_rows(io_target_expr) %>%
    dplyr::filter(!is.na(entrez)) %>%
    dplyr::distinct(entrez)

  # driver_mutations ---------------------------------------------------
  cat_genes_status("Get the driver_mutation values from feather files.")
  driver_mutations <- iatlas.data::get_tcga_driver_mutations_cached() %>%
    dplyr::distinct(entrez)

  # immunomodulators ---------------------------------------------------
  cat_genes_status("Get the immunomodulators values from feather files.")
  immunomodulators <- iatlas.data::get_tcga_immunomodulator_genes_cached() %>%
    dplyr::distinct(entrez, friendly_name, gene_family, gene_function, immune_checkpoint, super_category, references)

  # io_targets ---------------------------------------------------
  cat_genes_status("Get the io targets values from feather files.")
  io_targets <- iatlas.data::get_tcga_io_target_genes_cached() %>%
    dplyr::distinct(entrez, description, io_landscape_name, pathway, therapy_type, link)

  # tcga gene data ---------------------------------------------------
  cat_genes_status("Bind all genes together.")
  genes <- expr_genes %>%
    dplyr::bind_rows(dplyr::tibble(
      entrez = numeric(),
      description = character(),
      friendly_name = character(),
      io_landscape_name = character(),
      gene_family = character(),
      gene_function = character(),
      immune_checkpoint = character(),
      node_type = character(),
      pathway = character(),
      references = character(),
      super_category = character(),
      therapy_type = character()
    ), driver_mutations, io_targets, immunomodulators)

  cat_genes_status("Ensure no dupes.")
  genes <- genes %>% iatlas.data::resolve_df_dupes(keys = c("entrez"))

  cat_genes_status("Combine links and references.")
  genes <- genes %>% dplyr::mutate(references = iatlas.data::combine_references_and_links(references, link))

  cat_genes_status("Clean up the gene data")
  genes <- genes %>%
    dplyr::distinct(entrez, description, friendly_name, gene_family, gene_function, immune_checkpoint, io_landscape_name, pathway, references, super_category, therapy_type) %>%
    dplyr::arrange(entrez)

  # ecn genes ---------------------------------------------------
  cat_genes_status("Import extra cellular network (ecn) feather files for genes")
  ecn_values <- iatlas.data::read_iatlas_data_file(feather_file_folder, "network_node_label_friendly.feather")

  ecn_genes <- ecn_values %>%
    dplyr::rename(node_type = Type) %>%
    dplyr::rename(hgnc = Obj) %>%
    dplyr::left_join(human_gene_ids, by = "hgnc") %>%
    dplyr::distinct(entrez, friendly_name = FriendlyName, node_type) %>%
    dplyr::filter(!is.na(entrez)) %>%
    dplyr::arrange(entrez)

  # Create feather files ---------------------------------------------------
  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$human_gene_ids <- human_gene_ids %>%
    feather::write_feather(paste0(feather_file_folder, "/genes/human_gene_ids.feather"))

  .GlobalEnv$tcga_genes <- genes %>%
    feather::write_feather(paste0(feather_file_folder, "/genes/tcga_genes.feather"))

  .GlobalEnv$tcga_ecn_genes <- ecn_genes %>%
    feather::write_feather(paste0(feather_file_folder, "/genes/tcga_ecn_genes.feather"))

  # Clean up ---------------------------------------------------
  # Data
  rm(human_gene_ids, pos = ".GlobalEnv")
  rm(tcga_genes, pos = ".GlobalEnv")
  rm(tcga_ecn_genes, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
