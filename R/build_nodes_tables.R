build_nodes_tables <- function() {

  # nodes import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for nodes."), fill = TRUE)
  nodes <- iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "nodes")
  cat(crayon::blue("Imported feather files for nodes."), fill = TRUE)

  # nodes column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring nodes have all the correct columns and no dupes."), fill = TRUE)
  nodes <- nodes %>%
    dplyr::bind_rows(dplyr::tibble(
      entrez = numeric(),
      feature = character(),
      label = character(),
      tag = character(),
      score = numeric(),
      x = numeric(),
      y = numeric()
    )) %>%
    dplyr::filter(!is.na(entrez) | !is.na(feature)) %>%
    dplyr::distinct() %>%
    dplyr::arrange(entrez, feature)
  cat(crayon::blue("Ensured nodes have all the correct columns and no dupes."), fill = TRUE)

  # nodes data ---------------------------------------------------
  cat(crayon::magenta("Building the nodes data."), fill = TRUE)
  nodes <- nodes %>%
    dplyr::left_join(
      iatlas.data::get_genes() %>%
        dplyr::select(gene_id, entrez),
      by = "entrez"
    )

  nodes <- nodes %>% dplyr::left_join(iatlas.data::get_features(), by = "feature")

  nodes <- nodes %>% tibble::add_column(node_id = 1:nrow(nodes), .before = "entrez")
  cat(crayon::blue("Built the nodes data."), fill = TRUE)

  # nodes table ---------------------------------------------------
  cat(crayon::magenta("Building the nodes table."), fill = TRUE)
  table_written <- nodes %>%
    dplyr::select(id = node_id, feature_id, gene_id, score, x, y) %>%
    iatlas.data::replace_table("nodes")
  cat(crayon::blue("Built the nodes table. (", nrow(nodes), "rows )"), fill = TRUE, sep = " ")

  # nodes_to_tags data ---------------------------------------------------
  cat(crayon::magenta("Building the nodes_to_tags data."), fill = TRUE)
  node_tag_column_names <- iatlas.data::get_tag_column_names(nodes)

  nodes_to_tags <- nodes %>%
    tidyr::pivot_longer(node_tag_column_names, names_to = "delete", values_to = "tag") %>%
    dplyr::select(-c("delete"))

  nodes_to_tags <- nodes_to_tags %>% dplyr::left_join(iatlas.data::get_tags(), by = "tag")

  nodes_to_tags <- nodes_to_tags %>%
    dplyr::filter(!is.na(tag_id)) %>%
    dplyr::distinct(node_id, tag_id)
  cat(crayon::blue("Built the nodes_to_tags data."), fill = TRUE)

  # nodes_to_tags table ---------------------------------------------------
  cat(crayon::magenta("Building the nodes_to_tags table.\n\t(There are", nrow(nodes_to_tags), "rows to write, this may take a little while.)"), fill = TRUE, sep = " ")
  table_written <- nodes_to_tags %>% iatlas.data::replace_table("nodes_to_tags")
  cat(crayon::blue("Built the nodes_to_tags table. (", nrow(nodes_to_tags), "rows )"), fill = TRUE, sep = " ")

  # edges import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for edges."), fill = TRUE)
  edges <- iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "edges")
  cat(crayon::blue("Imported feather files for edges."), fill = TRUE)

  # edges column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring edges have all the correct columns and no dupes."), fill = TRUE)
  edges <- edges %>%
    dplyr::bind_rows(dplyr::tibble(
      from = character(),
      to = character(),
      label = character(),
      tag = character(),
      score = numeric()
    )) %>%
    dplyr::filter(!is.na(from) & !is.na(to)) %>%
    dplyr::distinct() %>%
    dplyr::arrange(from, to)
  cat(crayon::blue("Ensured edges have all the correct columns and no dupes."), fill = TRUE)

  # edges data ---------------------------------------------------
  cat(crayon::magenta("Building the edges data."), fill = TRUE)
  edges <- edges %>% dplyr::left_join(
    nodes %>%
      dplyr::filter(!is.na(entrez)) %>%
      dplyr::select(node_1_id = node_id, entrez, node_tag_column_names) %>%
      dplyr::mutate(entrez = entrez %>% as.character()),
    by = c("from" = "entrez", node_tag_column_names)
  )

  edges <- edges %>% dplyr::left_join(
    nodes %>%
      dplyr::filter(!is.na(feature)) %>%
      dplyr::select(node_1_id = node_id, feature, node_tag_column_names),
    by = c("from" = "feature", node_tag_column_names)
  )

  edges <- edges %>%
    dplyr::mutate(node_1_id = ifelse(is.na(node_1_id.x), node_1_id.y, node_1_id.x)) %>%
    dplyr::select(-c("node_1_id.y", "node_1_id.x"))

  edges <- edges %>% dplyr::left_join(
    nodes %>%
      dplyr::filter(!is.na(entrez)) %>%
      dplyr::select(node_2_id = node_id, entrez, node_tag_column_names) %>%
      dplyr::mutate(entrez = entrez %>% as.character()),
    by = c("to" = "entrez", node_tag_column_names)
  )

  edges <- edges %>% dplyr::left_join(
    nodes %>%
      dplyr::filter(!is.na(feature)) %>%
      dplyr::select(node_2_id = node_id, feature, node_tag_column_names),
    by = c("to" = "feature", node_tag_column_names)
  )

  edges <- edges %>% dplyr::mutate(node_2_id = ifelse(is.na(node_2_id.x), node_2_id.y, node_2_id.x))

  edges <- edges %>%
    dplyr::distinct(node_1_id, node_2_id, score) %>%
    dplyr::arrange(node_1_id, node_2_id, score)
  cat(crayon::blue("Built the edges data."), fill = TRUE)

  # edges table ---------------------------------------------------
  cat(crayon::magenta("Building the edges table.\n\t(There are", nrow(edges), "rows to write, this may take a little while.)"), fill = TRUE, sep = " ")
  table_written <- edges %>% iatlas.data::replace_table("edges")
  cat(crayon::blue("Built the edges table. (", nrow(edges), "rows )"), fill = TRUE, sep = " ")
}
