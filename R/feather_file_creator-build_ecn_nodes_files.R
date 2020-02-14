build_ecn_nodes_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_ecn_nodes_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  apply_path <- function(sub_path) {
    paste0("feather_files/SQLite_data/nodes/", sub_path)
  }

  current_pool <- pool::poolCheckout(.GlobalEnv$pool)

  fix_features <- function(df) {
    df %>% dplyr::rowwise() %>%
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
      ))
  }

  join_features <- function(df) {
    df %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("features") %>%
        dplyr::select(feature_id = id, node = name) %>%
        dplyr::as_tibble(),
      by = "node"
    ) %>%
      dplyr::filter(!is.na(feature_id)) %>%
      dplyr::rename(feature = node)
  }

  join_genes <- function(df) {
    df %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("genes") %>%
        dplyr::select(gene_id = id, entrez, node = hgnc) %>%
        dplyr::mutate_at(dplyr::vars(entrez), as.numeric) %>%
        dplyr::as_tibble(),
      by = "node"
    ) %>%
      dplyr::filter(!is.na(gene_id))
  }

  cat_ecn_nodes_status("Creating the nodes_TCGAImmune data.")
  nodes_TCGAImmune <- feather::read_feather(apply_path("nodes_TCGAImmune.feather")) %>%
    dplyr::distinct(node = Node, tag = Group, score = UpBinRatio) %>%
    fix_features() %>%
    dplyr::arrange(node, tag, score)
  features_nodes_TCGAImmune <- nodes_TCGAImmune %>% join_features()
  genes_nodes_TCGAImmune <- nodes_TCGAImmune %>% join_genes()
  nodes_TCGAImmune <- features_nodes_TCGAImmune %>%
    dplyr::bind_rows(genes_nodes_TCGAImmune) %>%
    dplyr::select(entrez, feature, tag, score)

  cat_ecn_nodes_status("Creating the nodes_TCGAStudy_Immune data.")
  nodes_TCGAStudy_Immune <- feather::read_feather(apply_path("nodes_TCGAStudy_Immune.feather")) %>%
    dplyr::distinct(node = Node, tag = Group, tag.01 = Immune, score = UpBinRatio) %>%
    fix_features() %>%
    dplyr::arrange(node, tag, score)
  features_nodes_TCGAStudy_Immune <- nodes_TCGAStudy_Immune %>% join_features()
  genes_nodes_TCGAStudy_Immune <- nodes_TCGAStudy_Immune %>% join_genes()
  nodes_TCGAStudy_Immune <- features_nodes_TCGAStudy_Immune %>%
    dplyr::bind_rows(genes_nodes_TCGAStudy_Immune) %>%
    dplyr::select(entrez, feature, tag, tag.01, score)

  cat_ecn_nodes_status("Creating the nodes_TCGAStudy data.")
  nodes_TCGAStudy <- feather::read_feather(apply_path("nodes_TCGAStudy.feather")) %>%
    dplyr::distinct(node = Node, tag = Group, score = UpBinRatio) %>%
    fix_features() %>%
    dplyr::arrange(node, tag, score)
  features_nodes_TCGAStudy <- nodes_TCGAStudy %>% join_features()
  genes_nodes_TCGAStudy <- nodes_TCGAStudy %>% join_genes()
  nodes_TCGAStudy <- features_nodes_TCGAStudy %>%
    dplyr::bind_rows(genes_nodes_TCGAStudy) %>%
    dplyr::select(entrez, feature, tag, score)

  cat_ecn_nodes_status("Creating the nodes_TCGASubtype data.")
  nodes_TCGASubtype <- feather::read_feather(apply_path("nodes_TCGASubtype.feather")) %>%
    dplyr::distinct(node = Node, tag = Group, score = UpBinRatio) %>%
    fix_features() %>%
    dplyr::arrange(node, tag, score)
  features_nodes_TCGASubtype <- nodes_TCGASubtype %>% join_features()
  genes_nodes_TCGASubtype <- nodes_TCGASubtype %>% join_genes()
  nodes_TCGASubtype <- features_nodes_TCGASubtype %>%
    dplyr::bind_rows(genes_nodes_TCGASubtype) %>%
    dplyr::select(entrez, feature, tag, score)

  pool::poolReturn(current_pool)

  .GlobalEnv$nodes_TCGAImmune <- nodes_TCGAImmune %>%
    feather::write_feather(paste0(getwd(), "/feather_files/nodes/nodes_TCGAImmune.feather"))

  .GlobalEnv$nodes_TCGAStudy_Immune <- nodes_TCGAStudy_Immune %>%
    feather::write_feather(paste0(getwd(), "/feather_files/nodes/nodes_TCGAStudy_Immune.feather"))

  .GlobalEnv$nodes_TCGAStudy <- nodes_TCGAStudy %>%
    feather::write_feather(paste0(getwd(), "/feather_files/nodes/nodes_TCGAStudy.feather"))

  .GlobalEnv$nodes_TCGASubtype <- nodes_TCGASubtype %>%
    feather::write_feather(paste0(getwd(), "/feather_files/nodes/nodes_TCGASubtype.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(nodes_TCGAImmune, pos = ".GlobalEnv")
  rm(nodes_TCGAStudy_Immune, pos = ".GlobalEnv")
  rm(nodes_TCGAStudy, pos = ".GlobalEnv")
  rm(nodes_TCGASubtype, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
