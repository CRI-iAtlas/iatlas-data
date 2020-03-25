get_tcga_cytokine_nodes <- function() {
  iatlas.data::create_global_synapse_connection()
  labels <- "syn21783989" %>%
    iatlas.data::synapse_feather_id_to_tbl() %>%
    dplyr::select(node = Obj, label = Type)

  cytokine_cells <- c(
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

  node_tbl <-
    c("syn21781358", "syn21781359", "syn21781360", "syn21781362") %>%
    purrr::map(iatlas.data::synapse_feather_id_to_tbl) %>%
    dplyr::bind_rows() %>%
    dplyr::select(
      node  = Node,
      tag   = Group,
      score = UpBinRatio,
      tag.2 = Immune
    ) %>%
    dplyr::left_join(labels, by = "node")

  feature_node_tbl <- node_tbl %>%
    dplyr::filter(node %in% cytokine_cells) %>%
    dplyr::rename(feature = node) %>%
    dplyr::mutate(feature = paste0(feature, "_Aggregate2"))

  tumor_node_tbl <- node_tbl %>%
    dplyr::filter(node == "Tumor_cell") %>%
    dplyr::select(-node) %>%
    dplyr::mutate(feature = "Tumor_fraction")

  gene_node_tbl <- node_tbl %>%
    dplyr::filter(!node %in% cytokine_cells) %>%
    dplyr::mutate(feature = NA) %>%
    dplyr::left_join(iatlas.data::get_master_gene_ids_cached(), by = c("node" = "hgnc")) %>%
    dplyr::select(-node) %>%
    dplyr::mutate_at(dplyr::vars(entrez), as.numeric)

  dplyr::bind_rows(feature_node_tbl, gene_node_tbl, tumor_node_tbl) %>%
    dplyr::filter(!is.na(tag))

}

get_tcga_cytokine_edges <- function() {
  iatlas.data::create_global_synapse_connection()
  edge_tbl <-
    c("syn21781350", "syn21781351", "syn21781354", "syn21781357") %>%
    purrr::map(iatlas.data::synapse_feather_id_to_tbl) %>%
    dplyr::bind_rows() %>%
    dplyr::select(
      from  = From,
      to    = To,
      score = ratioScore,
      tag   = Group,
      tag.2 = Immune
    ) %>%
    dplyr::left_join(iatlas.data::get_master_gene_ids_cached(), by = c("from" = "hgnc")) %>%
    dplyr::mutate(from = dplyr::if_else(
      is.na(entrez),
      paste0(from, "_Aggregate2"),
      as.character(entrez)
    )) %>%
    dplyr::select(-entrez) %>%
    dplyr::left_join(iatlas.data::get_master_gene_ids_cached(), by = c("to" = "hgnc")) %>%
    dplyr::mutate(to = dplyr::if_else(
      is.na(entrez),
      paste0(to, "_Aggregate2"),
      as.character(entrez)
    )) %>%
    dplyr::select(-entrez) %>%
    dplyr::filter(!is.na(tag))
}
