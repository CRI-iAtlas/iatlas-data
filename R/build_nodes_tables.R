build_nodes_tables <- function(...) {

  # nodes import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for nodes."), fill = TRUE)
  nodes <- synapse_read_all_feather_files("syn22126180")
  cat(crayon::blue("Imported feather files for nodes."), fill = TRUE)

  # nodes column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring nodes have all the correct columns and no dupes."), fill = TRUE)
  nodes <- nodes %>%
    dplyr::bind_rows(dplyr::tibble(
      entrez = numeric(),
      feature = character(),
      tag = character(),
      dataset = character(),
      network = character(),
      score = numeric(),
      x = numeric(),
      y = numeric()
    )) %>%
    dplyr::filter(
      !is.na(entrez),
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
    dplyr::arrange(dataset, network, entrez, feature)

    node_tag_column_names <- c(
      iatlas.data::get_tag_column_names(nodes),
      "network"
    )


    nodes <- nodes %>%
      iatlas.data::resolve_df_dupes(keys = c("entrez", "feature", "dataset", "network", node_tag_column_names)) %>%
      replace(. == "NA", NA) %>%
      dplyr::mutate_at(dplyr::vars(entrez, score, x, y), as.numeric)
  cat(crayon::blue("Ensured nodes have all the correct columns and no dupes."), fill = TRUE)

  # nodes data ---------------------------------------------------
  cat(crayon::magenta("Building the nodes data."), fill = TRUE)
  nodes <- nodes %>% dplyr::left_join(
    iatlas.data::get_genes() %>%
      dplyr::select(gene_id, entrez),
    by = "entrez"
  )

  nodes <- nodes %>% dplyr::left_join(iatlas.data::get_features(), by = "feature")

  nodes <- nodes %>% dplyr::inner_join(iatlas.data::get_datasets(), by = "dataset")

  nodes <- nodes %>% tibble::add_column(node_id = 1:nrow(nodes), .before = "entrez")



  cat(crayon::blue("Built the nodes data."), fill = TRUE)

  # nodes table ---------------------------------------------------
  cat(crayon::magenta("Building the nodes table."), fill = TRUE)
  table_written <- nodes %>%
    dplyr::select(id = node_id, dataset_id, feature_id, gene_id, score, x, y) %>%
    iatlas.data::replace_table("nodes")
  cat(crayon::blue("Built the nodes table. (", nrow(nodes), "rows )"), fill = TRUE, sep = " ")

  # nodes_to_tags data ---------------------------------------------------
  cat(crayon::magenta("Building the nodes_to_tags data."), fill = TRUE)
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
  edges <- synapse_read_all_feather_files("syn22126181")
  cat(crayon::blue("Imported feather files for edges."), fill = TRUE)

  # edges column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring edges have all the correct columns and no dupes."), fill = TRUE)
  edges <- edges %>%
    dplyr::bind_rows(dplyr::tibble(
      from = character(),
      to = character(),
      tag = character(),
      label = character(),
      score = numeric()
    )) %>%
    dplyr::filter(!is.na(from) & !is.na(to)) %>%
    replace(is.na(.), "NA") %>%
    dplyr::mutate(label = ifelse(label == "NA", NA, label)) %>%
    dplyr::distinct() %>%
    iatlas.data::resolve_df_dupes(
      .,
      keys = c("from", "to", "network", "dataset", node_tag_column_names)
    ) %>%
    replace(. == "NA", NA) %>%
    dplyr::mutate(label = ifelse(label == "NA", NA, label)) %>%
    dplyr::mutate_at(dplyr::vars(score), as.numeric) %>%
    dplyr::arrange(from, to, tag, score)
  cat(crayon::blue("Ensured edges have all the correct columns and no dupes."), fill = TRUE)

  # edges data ---------------------------------------------------
  cat(crayon::magenta("Building the edges data."), fill = TRUE)

  # Build node_1_id

  all_edges <- edges %>% dplyr::left_join(
    nodes %>%
      dplyr::filter(!is.na(entrez)) %>%
      dplyr::select(node_1_id = node_id, from = entrez, node_tag_column_names) %>%
      dplyr::mutate(from = from %>% as.character()),
    by = c("from", node_tag_column_names)
  )

  gene_edges <- all_edges %>% dplyr::filter(!is.na(node_1_id))

  feature_edges <- all_edges %>% dplyr::filter(is.na(node_1_id)) %>% dplyr::select(-node_1_id)

  feature_edges <- feature_edges %>%
    dplyr::left_join(
      nodes %>%
        dplyr::filter(!is.na(feature)) %>%
        dplyr::select(node_1_id = node_id, from = feature, node_tag_column_names),
      by = c("from", node_tag_column_names)
    ) %>%
    dplyr::filter(!is.na(node_1_id))

  edges <- gene_edges %>% dplyr::bind_rows(feature_edges)

  # Build node_2_id

  all_edges <- edges %>% dplyr::left_join(
    nodes %>%
      dplyr::filter(!is.na(entrez)) %>%
      dplyr::select(node_2_id = node_id, to = entrez, node_tag_column_names) %>%
      dplyr::mutate(to = to %>% as.character()),
    by = c("to", node_tag_column_names)
  )

  gene_edges <- all_edges %>% dplyr::filter(!is.na(node_2_id))

  feature_edges <- all_edges %>% dplyr::filter(is.na(node_2_id)) %>% dplyr::select(-node_2_id)

  feature_edges <- feature_edges %>% dplyr::left_join(
    nodes %>%
      dplyr::filter(!is.na(feature)) %>%
      dplyr::select(node_2_id = node_id, to = feature, node_tag_column_names),
    by = c("to", node_tag_column_names)
  ) %>%
    dplyr::filter(!is.na(node_2_id))

  edges <- gene_edges %>% dplyr::bind_rows(feature_edges)

  # clean up
  edges <- edges %>%
    dplyr::distinct(node_1_id, node_2_id, score) %>%
    dplyr::arrange(node_1_id, node_2_id, score)
  cat(crayon::blue("Built the edges data."), fill = TRUE)

  # edges table ---------------------------------------------------
  cat(crayon::magenta("Building the edges table.\n\t(There are", nrow(edges), "rows to write, this may take a little while.)"), fill = TRUE, sep = " ")
  table_written <- edges %>% iatlas.data::replace_table("edges")
  cat(crayon::blue("Built the edges table. (", nrow(edges), "rows )"), fill = TRUE, sep = " ")
}
