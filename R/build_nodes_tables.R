build_nodes_tables <- function() {

  # nodes import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for nodes."), fill = TRUE)
  nodes <- synapse_read_all_feather_files("syn22126180")
  cat(crayon::blue("Imported feather files for nodes."), fill = TRUE)

  # nodes column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring nodes have all the correct columns and no dupes."), fill = TRUE)
  nodes <- nodes %>%
    dplyr::bind_rows(dplyr::tibble(
      name = character(),
      entrez = numeric(),
      feature = character(),
      tag = character(),
      dataset = character(),
      network = character(),
      score = numeric(),
      x = numeric(),
      y = numeric(),
      label = character()
    )) %>%
    dplyr::filter(
      !is.na(tag),
      !is.na(name),
      !is.na(network),
      !is.na(dataset)
    ) %>%
    dplyr::mutate_at(dplyr::vars(entrez), as.character()) %>%
    replace(is.na(.), "NA") %>%
    dplyr::mutate(
      x = ifelse(x == "NA", NA, x),
      y = ifelse(y == "NA", NA, y)
    ) %>%
    dplyr::distinct() %>%
    dplyr::arrange(dataset, network, entrez, feature, name)

  node_tag_column_names <- c(
    iatlas.data::get_tag_column_names(nodes),
    "network"
  )

  nodes <- nodes %>%
    iatlas.data::resolve_df_dupes(keys = c("entrez", "feature", "dataset", node_tag_column_names)) %>%
    iatlas.data::resolve_df_dupes(keys = "name") %>%
    replace(. == "NA", NA) %>%
    dplyr::mutate_at(dplyr::vars(entrez, score, x, y), as.numeric)
  cat(crayon::blue("Ensured nodes have all the correct columns and no dupes."), fill = TRUE)

  # nodes data ---------------------------------------------------
  cat(crayon::magenta("Building the nodes data."), fill = TRUE)
  nodes <- nodes %>%
    dplyr::left_join(
      iatlas.data::get_genes() %>%
        dplyr::select(gene_id, entrez),
      by = "entrez"
    ) %>%
    dplyr::left_join(iatlas.data::get_features(), by = "feature") %>%
    dplyr::inner_join(iatlas.data::get_datasets(), by = "dataset")

  cat(crayon::blue("Built the nodes data."), fill = TRUE)

  # nodes table ---------------------------------------------------
  cat(crayon::magenta("Building the nodes table."), fill = TRUE)
  table_written <- nodes %>%
    dplyr::select(name, dataset_id, feature_id, gene_id, score, x, y) %>%
    iatlas.data::replace_table("nodes")
  cat(crayon::blue("Built the nodes table. (", nrow(nodes), "rows )"), fill = TRUE, sep = " ")

  rm(table_written)

  # nodes_to_tags data ---------------------------------------------------
  cat(crayon::magenta("Building the nodes_to_tags data."), fill = TRUE)
  nodes_to_tags <- nodes %>%
    dplyr::select(c("name", node_tag_column_names)) %>%
    tidyr::pivot_longer(node_tag_column_names, names_to = "delete", values_to = "tag") %>%
    dplyr::select(-c("delete")) %>%
    dplyr::left_join(iatlas.data::get_tags(), by = "tag") %>%
    dplyr::left_join(iatlas.data::get_nodes(), by = "name") %>%
    dplyr::select(tag_id, node_id) %>%
    tidyr::drop_na() %>%
    dplyr::distinct()
  cat(crayon::blue("Built the nodes_to_tags data."), fill = TRUE)

  # nodes_to_tags table ---------------------------------------------------
  cat(crayon::magenta("Building the nodes_to_tags table.\n\t(There are", nrow(nodes_to_tags), "rows to write, this may take a little while.)"), fill = TRUE, sep = " ")
  table_written <- nodes_to_tags %>% iatlas.data::replace_table("nodes_to_tags")
  cat(crayon::blue("Built the nodes_to_tags table. (", nrow(nodes_to_tags), "rows )"), fill = TRUE, sep = " ")

  rm(nodes_to_tags, table_written)
  # edges import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for edges."), fill = TRUE)
  edges <- synapse_read_all_feather_files("syn22126181")
  cat(crayon::blue("Imported feather files for edges."), fill = TRUE)

  # edges column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring edges have all the correct columns and no dupes."), fill = TRUE)
  edges <- edges %>%
    dplyr::bind_rows(dplyr::tibble(
      node1 = character(),
      node2 = character(),
      label = character(),
      score = numeric(),
      name = character()
    )) %>%
    dplyr::filter(
      !is.na(name),
      !is.na(node1),
      !is.na(node2),
    ) %>%
    replace(is.na(.), "NA") %>%
    dplyr::distinct() %>%
    iatlas.data::resolve_df_dupes(., keys = c("node1", "node2")) %>%
    iatlas.data::resolve_df_dupes(., keys = "name") %>%
    replace(. == "NA", NA) %>%
    dplyr::arrange(node1, node2, name)
  cat(crayon::blue("Ensured edges have all the correct columns and no dupes."), fill = TRUE)

  # edges data ---------------------------------------------------
  cat(crayon::magenta("Building the edges data."), fill = TRUE)

  # nodes <- nodes %>%
  #   dplyr::select("dataset", "network", "id", "node_id")

  edges <- edges %>%
    dplyr::left_join(iatlas.data::get_nodes(), by = c("node1" = "name")) %>%
    dplyr::rename("node_1_id" = "node_id") %>%
    dplyr::left_join(iatlas.data::get_nodes(), by = c("node2" = "name")) %>%
    dplyr::rename("node_2_id" = "node_id") %>%
    dplyr::select("score", "node_1_id", "node_2_id", "name", "label") %>%
    dplyr::distinct() %>%
    dplyr::arrange(node_1_id, node_2_id, name)
  cat(crayon::blue("Built the edges data."), fill = TRUE)

  # edges table ---------------------------------------------------
  cat(crayon::magenta("Building the edges table.\n\t(There are", nrow(edges), "rows to write, this may take a little while.)"), fill = TRUE, sep = " ")
  table_written <- edges %>% iatlas.data::replace_table("edges")
  cat(crayon::blue("Built the edges table. (", nrow(edges), "rows )"), fill = TRUE, sep = " ")
}
