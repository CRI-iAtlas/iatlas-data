get_tcga_cytokine_nodes <- function(){
  gene_ids <- feather::read_feather("feather_files/gene_ids.feather") %>%
    tidyr::drop_na() %>%
    dplyr::group_by(hgnc) %>%
    dplyr::arrange(entrez) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup()

  cells <- c(
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
    purrr::map(synapse_feather_id_to_tbl) %>%
    dplyr::bind_rows() %>%
    dplyr::select(
      node  = Node,
      tag   = Group,
      score = UpBinRatio,
      tag.2 = Immune
    )

  feature_node_tbl <- node_tbl %>%
    dplyr::filter(node %in% cells) %>%
    dplyr::rename(feature = node) %>%
    dplyr::mutate(
      feature = paste0(feature, "_Aggregate2"),
      gene = NA
    )

  tumor_node_tbl <- node_tbl %>%
    dplyr::filter(node == "Tumor_cell") %>%
    dplyr::select(-node) %>%
    dplyr::mutate(
      feature = "Tumor_Fraction",
      gene = NA
    )

  gene_node_tbl <- node_tbl %>%
    dplyr::filter(!node %in% cells) %>%
    dplyr::mutate(feature = NA) %>%
    dplyr::left_join(gene_ids, by = c("node" = "hgnc")) %>%
    dplyr::select(-node) %>%
    dplyr::rename(gene = entrez)

  dplyr::bind_rows(feature_node_tbl, gene_node_tbl, tumor_node_tbl) %>%
    dplyr::filter(!is.na(tag))
}

get_tcga_cytokine_edges <- function(){
  gene_ids <- feather::read_feather("feather_files/gene_ids.feather") %>%
    tidyr::drop_na() %>%
    dplyr::group_by(hgnc) %>%
    dplyr::arrange(entrez) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup()

  cells <- c(
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

  edge_tbl <-
    c("syn21781350", "syn21781351", "syn21781354", "syn21781357") %>%
    purrr::map(synapse_feather_id_to_tbl) %>%
    dplyr::bind_rows() %>%
    dplyr::select(
      from  = From,
      to    = To,
      score = ratioScore,
      tag   = Group,
      tag.2 = Immune
    ) %>%
    dplyr::left_join(gene_ids, by = c("from" = "hgnc")) %>%
    dplyr::mutate(from = dplyr::if_else(
      is.na(entrez),
      paste0(from, "_Aggregate2"),
      entrez
    )) %>%
    dplyr::select(-entrez) %>%
    dplyr::left_join(gene_ids, by = c("to" = "hgnc")) %>%
    dplyr::mutate(to = dplyr::if_else(
      is.na(entrez),
      paste0(to, "_Aggregate2"),
      entrez
    )) %>%
    dplyr::select(-entrez) %>%
    dplyr::filter(!is.na(tag))
}

synapse_feather_id_to_tbl <- function(id){
  id %>%
    .GlobalEnv$synapse$get() %>%
    purrr::pluck("path") %>%
    feather::read_feather(.) %>%
    dplyr::as_tibble()
}



