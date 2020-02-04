build_nodes_tables <- function(feather_file_folder) {

  cat(crayon::magenta("Importing feather files for nodes."), fill = TRUE)
  nodes <- read_iatlas_data_file(feather_file_folder, "nodes") %>%
    dplyr::distinct(hgnc = Node, tag.01 = Group, tag.02 = Immune, score = UpBinRatio) %>%
    dplyr::arrange(hgnc, tag.01, tag.02, score)
  cat(crayon::blue("Imported feather files for nodes."), fill = TRUE)

  cat(crayon::magenta("Building the nodes data."), fill = TRUE)
  # This should be use the entrez instead of the hgnc.
  nodes <- nodes %>%
    dplyr::left_join(get_genes(), by = "hgnc") %>%
    dplyr::arrange(hgnc, tag.01, tag.02, score) %>%
    tibble::add_column(node_id = 1:nrow(nodes), .before = "hgnc")
  cat(crayon::blue("Built the nodes data."), fill = TRUE)

  cat(crayon::magenta("Building the nodes table."), fill = TRUE)
  table_written <- nodes %>%
    dplyr::select(id = node_id, gene_id, score) %>%
    iatlas.data::replace_table("nodes")
  cat(crayon::blue("Built the nodes table. (", nrow(nodes), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building the nodes_to_tags data."), fill = TRUE)
  tags <- iatlas.data::read_table("tags") %>% dplyr::as_tibble()

  node_set_group <- nodes %>%
    dplyr::left_join(
      tags %>% dplyr::select(tag_id = id, tag.01 = name),
      by = "tag.01"
    ) %>%
    dplyr::filter(!is.na(tag_id))

  node_set_immune <- nodes %>%
    dplyr::left_join(
      tags %>% dplyr::select(tag_id = id, tag.02 = name),
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
  edges <- read_iatlas_data_file(feather_file_folder, "edges") %>%
    dplyr::distinct(From, To, tag.01 = Group, tag.02 = Immune, score = ratioScore) %>%
    dplyr::arrange(From, To, tag.01, tag.02)
  cat(crayon::blue("Imported feather files for edges."), fill = TRUE)

  cat(crayon::magenta("Building the edges data."), fill = TRUE)
  edges <- edges %>%
    dplyr::left_join(
      nodes %>% dplyr::select(node_1_id = node_id, hgnc, tag.01, tag.02),
      by = c("From" = "hgnc", "tag.01" = "tag.01", "tag.02" = "tag.02")
    )

  edges <- edges %>%
    dplyr::left_join(
      nodes %>% dplyr::select(node_2_id = node_id, hgnc, tag.01, tag.02),
      by = c("To" = "hgnc", "tag.01" = "tag.01", "tag.02" = "tag.02")
    )

  edges <- edges %>%
    dplyr::distinct(node_1_id, node_2_id, score) %>%
    dplyr::arrange(node_1_id, node_2_id, score)
  cat(crayon::blue("Built the edges data."), fill = TRUE)

  cat(crayon::magenta("Building the edges table.\n\t(There are", nrow(edges), "rows to write, this may take a little while.)"), fill = TRUE, sep = " ")
  table_written <- edges %>% iatlas.data::replace_table("edges")
  cat(crayon::blue("Built the edges table. (", nrow(edges), "rows )"), fill = TRUE, sep = " ")
}
