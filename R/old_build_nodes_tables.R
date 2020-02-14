old_build_nodes_tables <- function() {

  cat(crayon::magenta("Importing feather files for nodes."), fill = TRUE)
  all_nodes <- iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "SQLite_data/nodes") %>%
    dplyr::distinct(node = Node, tag.01 = Group, tag.02 = Immune, score = UpBinRatio) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(node = ifelse(
      identical(node, "B_cells") |
        identical(node, "Dendritic_cells") |
        identical(node, "Eosinophils") |
        identical(node, "Macrophage") |
        identical(node, "Mast_cells") |
        identical(node, "Neutrophils") |
        identical(node, "NK_cells") |
        identical(node, "T_cells_CD4") |
        identical(node, "T_cells_CD8"),
        paste0(node, ".Aggregate2"),
        node
    )) %>%
    dplyr::arrange(node, tag.01, tag.02, score)
  cat(crayon::blue("Imported feather files for nodes."), fill = TRUE)

  cat(crayon::magenta("Building the nodes data."), fill = TRUE)
  gene_nodes <- all_nodes %>% dplyr::left_join(
    iatlas.data::old_read_genes() %>%
      dplyr::select(gene_id, node = hgnc),
    by = "node"
  ) %>%
    dplyr::filter(!is.na(gene_id))

  feature_nodes <- all_nodes %>% dplyr::left_join(
    iatlas.data::old_read_features() %>%
      dplyr::select(feature_id, node = feature),
    by = "node"
  ) %>%
    dplyr::filter(!is.na(feature_id))

  nodes <- gene_nodes %>% dplyr::bind_rows(feature_nodes)

  nodes <- nodes %>%
    dplyr::arrange(gene_id, feature_id, tag.01, tag.02, score) %>%
    tibble::add_column(node_id = 1:nrow(nodes), .before = "node")
  cat(crayon::blue("Built the nodes data."), fill = TRUE)

  cat(crayon::magenta("Building the nodes table."), fill = TRUE)
  table_written <- nodes %>%
    dplyr::select(id = node_id, gene_id, feature_id, score) %>%
    iatlas.data::replace_table("nodes")
  cat(crayon::blue("Built the nodes table. (", nrow(nodes), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building the nodes_to_tags data."), fill = TRUE)

  node_set_group <- nodes %>%
    dplyr::left_join(
      old_read_tags() %>% dplyr::select(tag_id, tag.01 = tag),
      by = "tag.01"
    ) %>%
    dplyr::filter(!is.na(tag_id))

  node_set_immune <- nodes %>%
    dplyr::left_join(
      old_read_tags() %>% dplyr::select(tag_id, tag.02 = tag),
      by = "tag.02"
    ) %>%
    dplyr::filter(!is.na(tag_id))

  nodes_to_tags <- node_set_group %>%
    dplyr::bind_rows(node_set_immune) %>%
    dplyr::distinct(node_id, tag_id)
  cat(crayon::blue("Built the nodes_to_tags data."), fill = TRUE)

  cat(crayon::magenta("Building the nodes_to_tags table.\n\t(There are", nrow(nodes_to_tags), "rows to write, this may take a little while.)"), fill = TRUE, sep = " ")
  table_written <- nodes_to_tags %>% iatlas.data::replace_table("nodes_to_tags")
  cat(crayon::blue("Built the nodes_to_tags table. (", nrow(nodes_to_tags), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Importing feather files for edges."), fill = TRUE)
  edges <- iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "SQLite_data/edges") %>%
    dplyr::distinct(From, To, tag.01 = Group, tag.02 = Immune, score = ratioScore) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      From = ifelse(
        identical(From, "B_cells") |
          identical(From, "Dendritic_cells") |
          identical(From, "Eosinophils") |
          identical(From, "Macrophage") |
          identical(From, "Mast_cells") |
          identical(From, "Neutrophils") |
          identical(From, "NK_cells") |
          identical(From, "T_cells_CD4") |
          identical(From, "T_cells_CD8"),
        paste0(From, ".Aggregate2"),
        From
      ),
      To = ifelse(
        identical(To, "B_cells") |
          identical(To, "Dendritic_cells") |
          identical(To, "Eosinophils") |
          identical(To, "Macrophage") |
          identical(To, "Mast_cells") |
          identical(To, "Neutrophils") |
          identical(To, "NK_cells") |
          identical(To, "T_cells_CD4") |
          identical(To, "T_cells_CD8"),
        paste0(To, ".Aggregate2"),
        To
      )
    ) %>%
    dplyr::arrange(From, To, tag.01, tag.02)
  cat(crayon::blue("Imported feather files for edges."), fill = TRUE)

  cat(crayon::magenta("Building the edges data."), fill = TRUE)
  edges <- edges %>% dplyr::left_join(
    nodes %>% dplyr::select(node_1_id = node_id, node, tag.01, tag.02),
    by = c("From" = "node", "tag.01" = "tag.01", "tag.02" = "tag.02")
  )

  edges <- edges %>% dplyr::left_join(
    nodes %>% dplyr::select(node_2_id = node_id, node, tag.01, tag.02),
    by = c("To" = "node", "tag.01" = "tag.01", "tag.02" = "tag.02")
  )

  edges <- edges %>%
    dplyr::distinct(node_1_id, node_2_id, score) %>%
    dplyr::arrange(node_1_id, node_2_id, score)
  cat(crayon::blue("Built the edges data."), fill = TRUE)

  cat(crayon::magenta("Building the edges table.\n\t(There are", nrow(edges), "rows to write, this may take a little while.)"), fill = TRUE, sep = " ")
  table_written <- edges %>% iatlas.data::replace_table("edges")
  cat(crayon::blue("Built the edges table. (", nrow(edges), "rows )"), fill = TRUE, sep = " ")

}
