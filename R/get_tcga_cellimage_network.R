cellimage_cells <- c(
  "B_cells",
  "Dendritic_cells",
  "Eosinophils",
  "Macrophage",
  "Mast_cells",
  "NK_cells",
  "Neutrophils",
  "T_cells_CD4",
  "T_cells_CD8"
)

get_tcga_cellimage_nodes <- function() {
  iatlas.data::create_global_synapse_connection()
  position_tbl <- iatlas.data::synapse_feather_id_to_tbl("syn21781366")
  nodes_tbl <- iatlas.data::get_tcga_cytokine_nodes_cached()

  cellimage_nodes <- "syn21782167" %>%
    iatlas.data::synapse_feather_id_to_tbl() %>%
    dplyr::select(From, To) %>%
    tidyr::pivot_longer(
      .,
      c("From", "To"),
      values_to = "node",
      names_to = "type"
    ) %>%
    dplyr::select(node) %>%
    dplyr::distinct() %>%
    dplyr::full_join(position_tbl, by = c(node = "Variable")) %>%
    dplyr::left_join(iatlas.data::get_master_gene_ids_cached(), by = c("node" = "hgnc")) %>%
    dplyr::mutate(node = dplyr::if_else(
      !is.na(entrez),
      as.character(entrez),
      dplyr::if_else(
        node %in% cellimage_cells,
        paste0(node, "_Aggregate2"),
        dplyr::if_else(
          node == "Tumor_cell",
          "Tumor_fraction",
          NA_character_
        )
      )
    )) %>%
    dplyr::select(-entrez)

  gene_nodes <- nodes_tbl %>%
    dplyr::mutate(entrez = as.character(entrez)) %>%
    dplyr::inner_join(cellimage_nodes, by = c("entrez" = "node")) %>%
    dplyr::mutate_at(dplyr::vars(entrez), as.numeric)

  feature_nodes <- nodes_tbl %>%
    dplyr::inner_join(cellimage_nodes, by = c("feature" = "node"))

  gene_nodes %>% dplyr::bind_rows(feature_nodes)
}

get_tcga_cellimage_edges <- function() {
  edges_tbl <- iatlas.data::get_tcga_cytokine_edges_cached()

  iatlas.data::create_global_synapse_connection()
  cellimage_edges <- "syn21782167" %>%
    iatlas.data::synapse_feather_id_to_tbl() %>%
    dplyr::select(from = From, to = To, label = interaction) %>%
    dplyr::left_join(iatlas.data::get_master_gene_ids_cached(), by = c("from" = "hgnc")) %>%
    dplyr::mutate(from = dplyr::if_else(
      !is.na(entrez),
      as.character(entrez),
      dplyr::if_else(
        from %in% cellimage_cells,
        paste0(from, "_Aggregate2"),
        dplyr::if_else(
          from == "Tumor_cell",
          "Tumor_fraction",
          NA_character_
        )
      )
    )) %>%
    dplyr::select(-entrez) %>%
    dplyr::left_join(iatlas.data::get_master_gene_ids_cached(), by = c("to" = "hgnc")) %>%
    dplyr::mutate(to = dplyr::if_else(
      !is.na(entrez),
      as.character(entrez),
      dplyr::if_else(
        to %in% cellimage_cells,
        paste0(to, "_Aggregate2"),
        dplyr::if_else(
          to == "Tumor_cell",
          "Tumor_fraction",
          NA_character_
        )
      )
    )) %>%
    dplyr::select(-entrez) %>%
    dplyr::full_join(edges_tbl, by = c("from", "to"))

}
