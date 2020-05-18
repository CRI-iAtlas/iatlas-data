get_tcga_cytokine_nodes_cached <- function() {
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "tcga_cytokine_nodes_synapse",
    iatlas.data::get_tcga_cytokine_nodes()
  )
}

get_tcga_cytokine_edges_cached <- function() {
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "tcga_cytokine_edges_synapse",
    iatlas.data::get_tcga_cytokine_edges()
  )
}

get_cellimage_nodes_cached <- function() {
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "tcga_cellimage_nodes_synapse",
    iatlas.data::get_tcga_cellimage_nodes()
  )
}

get_cellimage_edges_cached <- function() {
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "tcga_cellimage_edges_synapse",
    iatlas.data::get_tcga_cellimage_edges()
  )
}

get_tcga_copynumber_results_cached <- function() {
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "tcga_copynumber_results_synapse",
    iatlas.data::get_tcga_copynumber_results()
  )
}

get_tcga_driver_mutation_genes <- function() {
  iatlas.data::result_cached(
    "tcga_driver_mutation_genes",
    iatlas.data::read_iatlas_data_file(
      iatlas.data::get_feather_file_folder(),
      "SQLite_data/driver_mutations*.feather"
    ) %>%
      dplyr::distinct(hgnc = gene) %>%
      dplyr::arrange(hgnc)
  )
}

get_tcga_immunodulator_genes <- function() {
  iatlas.data::result_cached(
    "tcga_immunodulator_genes",
    iatlas.data::read_iatlas_data_file(
      iatlas.data::get_feather_file_folder(),
      "SQLite_data/immunomodulators.feather"
    ) %>%
      dplyr::filter(!is.na(gene)) %>%
      dplyr::rename(friendly_name = display2) %>%
      dplyr::rename(hgnc = gene) %>%
      dplyr::mutate(references = iatlas.data::build_references(reference)) %>%
      dplyr::select(-c("display", "entrez", "reference")) %>%
      dplyr::arrange(hgnc)
  )
}

get_tcga_io_target_genes <- function() {
  iatlas.data::result_cached(
    "tcga_io_target_genes",
    iatlas.data::read_iatlas_data_file(
      iatlas.data::get_feather_file_folder(),
      "SQLite_data/io_targets.feather"
    ) %>%
      dplyr::filter(!is.na(gene)) %>%
      dplyr::distinct(hgnc = gene, .keep_all = TRUE) %>%
      dplyr::select(-c("entrez")) %>%
      dplyr::rename(io_landscape_name = display2) %>%
      dplyr::mutate(references = iatlas.data::link_to_references(link)) %>%
      dplyr::select(-c("display", "link")) %>%
      dplyr::arrange(hgnc)
  )
}

get_tcga_io_target_expr_genes <- function() {
  iatlas.data::result_cached(
    "tcga_io_target_expr_genes",
    iatlas.data::read_iatlas_data_file(
      iatlas.data::get_feather_file_folder(),
      "SQLite_data/io_target_expr*.feather"
    ) %>%
      dplyr::distinct(hgnc = gene) %>%
      dplyr::arrange(hgnc)
  )
}

get_tcga_immunomodulator_expr_genes <- function() {
  iatlas.data::result_cached(
    "tcga_immunomodulator_expr_genes",
    iatlas.data::read_iatlas_data_file(
      iatlas.data::get_feather_file_folder(),
      "SQLite_data/immunomodulator_expr.feather"
    ) %>%
      dplyr::distinct(hgnc = gene) %>%
      dplyr::arrange(hgnc)
  )
}

get_tcga_ecn_genes <- function() {
  iatlas.data::result_cached(
    "tcga_ecn_genes",
    iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "ecn_genes.feather") %>%
      dplyr::select(-c("entrez")) %>%
      dplyr::arrange(hgnc)
  )
}
