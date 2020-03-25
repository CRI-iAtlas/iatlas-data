get_tcga_cytokine_nodes_cached <- function() {
  iatlas.data::result_cached(
    "tcga_cytokine_nodes_synapse",
    iatlas.data::get_tcga_cytokine_nodes()
  )
}

get_tcga_cytokine_edges_cached <- function() {
  iatlas.data::result_cached(
    "tcga_cytokine_edges_synapse",
    iatlas.data::get_tcga_cytokine_edges()
  )
}

get_cellimage_nodes_cached <- function() {
  iatlas.data::result_cached(
    "tcga_cellimage_nodes_synapse",
    iatlas.data::get_tcga_cellimage_nodes()
  )
}

get_cellimage_edges_cached <- function() {
  iatlas.data::result_cached(
    "tcga_cellimage_edges_synapse",
    iatlas.data::get_tcga_cellimage_edges()
  )
}

get_tcga_copynumber_results_cached <- function() {
  iatlas.data::result_cached(
    "tcga_copynumber_results_synapse",
    iatlas.data::get_tcga_copynumber_results()
  )
}

get_tcga_driver_mutations_cached <- function() {
  iatlas.data::result_cached("driver_mutations", iatlas.data::get_tcga_driver_mutations())
}

get_tcga_immunomodulator_exprs_cached <- function() {
  iatlas.data::result_cached(
    "immunomodulator_exprs",
    iatlas.data::read_iatlas_data_file(
      "feather_files",
      "SQLite_data/immunomodulator_expr.feather"
    ) %>%
      dplyr::rename(hgnc = gene) %>%
      dplyr::left_join(iatlas.data::get_gene_ids(), by = "hgnc") %>%
      dplyr::distinct(
        entrez,
        hgnc,
        tcga_study = TCGA_Study,
        tcga_subtype = TCGA_Subtype,
        immune_subtype = Immune_Subtype,
        sample,
        rna_seq_expr = value
      ) %>%
      dplyr::arrange(entrez, tcga_study, tcga_subtype, immune_subtype)
  )
}

get_tcga_immunomodulator_genes_cached <- function() {
  iatlas.data::result_cached(
    "immunomodulator_genes",
    iatlas.data::read_iatlas_data_file(
      "feather_files",
      "SQLite_data/immunomodulators.feather"
    ) %>%
      dplyr::filter(!is.na(entrez)) %>%
      dplyr::mutate_at(dplyr::vars(entrez), as.numeric) %>%
      dplyr::mutate(references = iatlas.data::build_references(reference)) %>%
      dplyr::distinct(entrez, hgnc = gene, friendly_name = display2, gene_family, gene_function, immune_checkpoint, super_category, references)
  )
}

get_tcga_io_target_exprs_cached <- function() {
  iatlas.data::result_cached(
    "io_target_exprs",
    immunomodulator_expr <- iatlas.data::read_iatlas_data_file(
      "feather_files",
      "SQLite_data/io_target_expr"
    ) %>%
      dplyr::rename(hgnc = gene) %>%
      dplyr::left_join(iatlas.data::get_gene_ids(), by = "hgnc") %>%
      dplyr::distinct(
        entrez,
        hgnc,
        tcga_study = TCGA_Study,
        tcga_subtype = TCGA_Subtype,
        immune_subtype = Immune_Subtype,
        sample,
        rna_seq_expr = value
      ) %>%
      dplyr::arrange(entrez, tcga_study, tcga_subtype, immune_subtype)
  )
}

# This also removes specific entrez duplicates.
get_tcga_io_target_genes_cached <- function() {
  iatlas.data::result_cached(
    "io_target_genes",
    iatlas.data::read_iatlas_data_file(
      "feather_files",
      "SQLite_data/io_targets.feather"
    ) %>%
      dplyr::filter(!is.na(entrez)) %>%
      dplyr::mutate_at(dplyr::vars(entrez), as.numeric) %>%
      dplyr::filter(
        display2 != "BTE6-LX-8b" &
          display2 != "BTE6-X-15-7" &
          display2 != "CD16a" &
          display2 != "EGFRvIII"
      ) %>%
      dplyr::distinct(entrez, hgnc = gene, io_landscape_name = display2, .keep_all = TRUE) %>%
      dplyr::mutate(link = iatlas.data::link_to_references(link))
  )
}
