get_tcga_cellimage_nodes <- function(){
  position_tbl <- iatlas.data::synapse_feather_id_to_tbl("syn21781366")
  nodes_tbl <- get_tcga_cytokine_nodes_cached()
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

  cellimage_nodes <- "syn21782167" %>%
    iatlas.data::synapse_feather_id_to_tbl(.) %>%
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
    dplyr::left_join(gene_ids, by = c("node" = "hgnc")) %>%
    dplyr::mutate(node = dplyr::if_else(
      !is.na(entrez),
      as.character(entrez),
      dplyr::if_else(
        node %in% cells,
        paste0(node, "_Aggregate2"),
        dplyr::if_else(
          node == "Tumor_cell",
          "Tumor_Fraction",
          NA_character_
        )
      )
    )) %>%
    dplyr::select(-entrez)

  nodes_tbl1 <- nodes_tbl %>%
    dplyr::mutate(gene = as.character(gene)) %>%
    dplyr::inner_join(cellimage_nodes, by = c("gene" = "node"))

  nodes_tbl2 <- nodes_tbl %>%
    dplyr::inner_join(cellimage_nodes, by = c("feature" = "node"))

  dplyr::bind_rows(nodes_tbl1, nodes_tbl2)
}

get_tcga_cellimage_edges <- function(){
  edges_tbl <- get_tcga_cytokine_edges_cached()
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

  cellimage_edges <- "syn21782167" %>%
    iatlas.data::synapse_feather_id_to_tbl(.) %>%
    dplyr::select(from = From, to = To, label = interaction) %>%
    dplyr::left_join(gene_ids, by = c("from" = "hgnc")) %>%
    dplyr::mutate(from = dplyr::if_else(
      !is.na(entrez),
      as.character(entrez),
      dplyr::if_else(
        from %in% cells,
        paste0(from, "_Aggregate2"),
        dplyr::if_else(
          from == "Tumor_cell",
          "Tumor_Fraction",
          NA_character_
        )
      )
    )) %>%
    dplyr::select(-entrez) %>%
    dplyr::left_join(gene_ids, by = c("to" = "hgnc")) %>%
    dplyr::mutate(to = dplyr::if_else(
      !is.na(entrez),
      as.character(entrez),
      dplyr::if_else(
        to %in% cells,
        paste0(to, "_Aggregate2"),
        dplyr::if_else(
          to == "Tumor_cell",
          "Tumor_Fraction",
          NA_character_
        )
      )
    )) %>%
    dplyr::select(-entrez) %>%
    dplyr::full_join(edges_tbl, by = c("from", "to"))

}
