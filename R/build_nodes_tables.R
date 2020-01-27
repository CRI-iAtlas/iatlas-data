build_nodes_tables <- function(feather_file_folder) {
  apply_path <- function(sub_path) {
    paste0(feather_file_folder, "/", sub_path)
  }

  cat(crayon::magenta("Importing feather files for nodes."), fill = TRUE)
  nodes <- iatlas.data::load_feather_data(apply_path("nodes")) %>%
    dplyr::distinct(Node, Group, Immune, UpBinRatio) %>%
    dplyr::arrange(Node, Group, Immune, UpBinRatio)
  cat(crayon::blue("Imported feather files for nodes."), fill = TRUE)

  cat(crayon::magenta("Building the nodes data."), fill = TRUE)
  nodes <- nodes %>%
    dplyr::rename_at("Node", ~("name")) %>%
    dplyr::left_join(
      iatlas.data::read_table("genes") %>%
        dplyr::select(id, hgnc) %>%
        dplyr::rename_at("id", ~("gene_id")) %>%
        dplyr::as_tibble(),
      by = c("name" = "hgnc")
    ) %>%
    dplyr::rename_at("UpBinRatio", ~("score")) %>%
    tibble::add_column(id = 1:nrow(nodes), .before = "name")
  cat(crayon::blue("Built the nodes data."), fill = TRUE)

  cat(crayon::magenta("Building the nodes table."), fill = TRUE)
  table_written <- nodes %>%
    dplyr::select(id, gene_id, score) %>%
    iatlas.data::write_table_ts("nodes")
  cat(crayon::blue("Built the nodes table. (", nrow(nodes), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building the nodes_to_tags data."), fill = TRUE)
  tags <- iatlas.data::read_table("tags") %>% dplyr::as_tibble()

  node_set_group <- nodes %>%
    dplyr::rename_at("id", ~("node_id")) %>%
    dplyr::inner_join(tags, by = c("Group" = "name")) %>%
    dplyr::rename_at("id", ~("tag_id"))

  node_set_immune <- nodes %>%
    dplyr::rename_at("id", ~("node_id")) %>%
    dplyr::inner_join(tags, by = c("Immune" = "name")) %>%
    dplyr::rename_at("id", ~("tag_id"))

  nodes_to_tags <- node_set_group %>%
    dplyr::bind_rows(node_set_immune) %>%
    dplyr::distinct(node_id, tag_id)
  cat(crayon::blue("Built the nodes_to_tags data."), fill = TRUE)

  cat(crayon::magenta("Building the nodes_to_tags table.\n(There are", nrow(nodes_to_tags), "rows to write, this may take a little while.)"), fill = TRUE, sep = " ")
  table_written <- nodes_to_tags %>% iatlas.data::write_table_ts("nodes_to_tags")
  cat(crayon::blue("Built the nodes_to_tags table. (", nrow(nodes_to_tags), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Importing feather files for edges."), fill = TRUE)
  edges <- iatlas.data::load_feather_data(apply_path("edges")) %>%
    dplyr::distinct(From, To, Group, Immune, ratioScore) %>%
    dplyr::rename_at("ratioScore", ~("score")) %>%
    dplyr::arrange(From, To, Group, Immune)
  cat(crayon::blue("Imported feather files for edges."), fill = TRUE)

  cat(crayon::magenta("Building the edges data."), fill = TRUE)
  edges <- edges %>%
    dplyr::inner_join(nodes, by = c("From" = "name", "Group" = "Group", "Immune" = "Immune")) %>%
    dplyr::rename_at("id", ~("node_1_id")) %>%
    dplyr::inner_join(nodes, by = c("To" = "name", "Group" = "Group", "Immune" = "Immune")) %>%
    dplyr::rename_at("id", ~("node_2_id")) %>%
    dplyr::distinct(node_1_id, node_2_id, score) %>%
    dplyr::arrange(node_1_id, node_2_id, score)
  cat(crayon::blue("Built the edges data."), fill = TRUE)

  cat(crayon::magenta("Building the edges table.\n(There are", nrow(edges), "rows to write, this may take a little while.)"), fill = TRUE, sep = " ")
  table_written <- edges %>% iatlas.data::write_table_ts("edges")
  cat(crayon::blue("Built the edges table. (", nrow(edges), "rows )"), fill = TRUE, sep = " ")
}
