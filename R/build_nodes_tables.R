build_nodes_tables <- function() {

  # nodes import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for nodes."), fill = TRUE)
  nodes <- iatlas.data::read_iatlas_data_file(get_feather_file_folder(), "nodes") %>%
    dplyr::distinct() %>%
    dplyr::arrange(entrez, hgnc)
  cat(crayon::blue("Imported feather files for nodes."), fill = TRUE)

  # nodes data ---------------------------------------------------
  cat(crayon::magenta("Building the nodes data."), fill = TRUE)
  # This should be use the entrez instead of the hgnc.
  nodes <- nodes %>%
    dplyr::left_join(get_genes(), by = "hgnc") %>%
    tibble::add_column(node_id = 1:nrow(nodes), .before = "hgnc")
  cat(crayon::blue("Built the nodes data."), fill = TRUE)

  # nodes table ---------------------------------------------------
  cat(crayon::magenta("Building the nodes table."), fill = TRUE)
  table_written <- nodes %>%
    dplyr::select(id = node_id, gene_id, score) %>%
    iatlas.data::replace_table("nodes")
  cat(crayon::blue("Built the nodes table. (", nrow(nodes), "rows )"), fill = TRUE, sep = " ")

  # nodes_to_tags data ---------------------------------------------------
  cat(crayon::magenta("Building the nodes_to_tags data."), fill = TRUE)
  node_tag_column_names <- iatlas.data::get_tag_column_names(nodes)

  nodes_to_tags <- nodes %>%
    tidyr::pivot_longer(node_tag_column_names, names_to = "delete", values_to = "tag") %>%
    dplyr::select(-c("delete"))

  nodes_to_tags <- nodes_to_tags %>% dplyr::left_join(
    iatlas.data::read_table("tags") %>%
      dplyr::as_tibble() %>%
      dplyr::select(tag_id = id, tag = name),
    by = "tag"
  )

  nodes_to_tags <- nodes_to_tags %>%
    dplyr::distinct(node_id, tag_id) %>%
    dplyr::filter(!is.na(tag_id))
  cat(crayon::blue("Built the nodes_to_tags data."), fill = TRUE)

  # nodes_to_tags table ---------------------------------------------------
  cat(crayon::magenta("Building the nodes_to_tags table.\n\t(There are", nrow(nodes_to_tags), "rows to write, this may take a little while.)"), fill = TRUE, sep = " ")
  table_written <- nodes_to_tags %>% iatlas.data::replace_table("nodes_to_tags")
  cat(crayon::blue("Built the nodes_to_tags table. (", nrow(nodes_to_tags), "rows )"), fill = TRUE, sep = " ")

  # edges import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for edges."), fill = TRUE)
  edges <- iatlas.data::read_iatlas_data_file(feather_file_folder, "edges") %>%
    dplyr::distinct() %>%
    dplyr::arrange(from, to)
  cat(crayon::blue("Imported feather files for edges."), fill = TRUE)

  cat(crayon::magenta("Building the edges data."), fill = TRUE)
  edges <- edges %>%
    dplyr::left_join(
      nodes %>% dplyr::rename(node_1_id = node_id),
      by = c("from" = "hgnc", node_tag_column_names)
    )

  edges <- edges %>%
    dplyr::left_join(
      nodes %>% dplyr::rename(node_2_id = node_id),
      by = c("to" = "hgnc", node_tag_column_names)
    )

  edges <- edges %>%
    dplyr::distinct(node_1_id, node_2_id, score) %>%
    dplyr::arrange(node_1_id, node_2_id, score)
  cat(crayon::blue("Built the edges data."), fill = TRUE)

  cat(crayon::magenta("Building the edges table.\n\t(There are", nrow(edges), "rows to write, this may take a little while.)"), fill = TRUE, sep = " ")
  table_written <- edges %>% iatlas.data::replace_table("edges")
  cat(crayon::blue("Built the edges table. (", nrow(edges), "rows )"), fill = TRUE, sep = " ")
}
