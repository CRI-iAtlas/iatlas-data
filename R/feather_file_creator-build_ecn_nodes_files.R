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

  cat_ecn_nodes_status("Creating the nodes_TCGAImmune data.")
  nodes_TCGAImmune <- feather::read_feather(apply_path("nodes_TCGAImmune.feather")) %>%
    dplyr::distinct(hgnc = Node, tag = Group, score = UpBinRatio) %>%
    dplyr::left_join(
      current_pool %>% dplyr::tbl("genes") %>%
        dplyr::select(entrez, hgnc) %>%
        dplyr::mutate_at(dplyr::vars(entrez), as.numeric) %>%
        dplyr::as_tibble(),
      by = "hgnc"
    )

  cat_ecn_nodes_status("Creating the nodes_TCGAStudy_Immune data.")
  nodes_TCGAStudy_Immune <- feather::read_feather(apply_path("nodes_TCGAStudy_Immune.feather")) %>%
    dplyr::distinct(hgnc = Node, tag = Group, tag.01 = Immune, score = UpBinRatio) %>%
    dplyr::left_join(
      current_pool %>% dplyr::tbl("genes") %>%
        dplyr::select(entrez, hgnc) %>%
        dplyr::mutate_at(dplyr::vars(entrez), as.numeric) %>%
        dplyr::as_tibble(),
      by = "hgnc"
    )

  cat_ecn_nodes_status("Creating the nodes_TCGAStudy data.")
  nodes_TCGAStudy <- feather::read_feather(apply_path("nodes_TCGAStudy.feather")) %>%
    dplyr::distinct(hgnc = Node, tag = Group, score = UpBinRatio) %>%
    dplyr::left_join(
      current_pool %>% dplyr::tbl("genes") %>%
        dplyr::select(entrez, hgnc) %>%
        dplyr::mutate_at(dplyr::vars(entrez), as.numeric) %>%
        dplyr::as_tibble(),
      by = "hgnc"
    )

  cat_ecn_nodes_status("Creating the nodes_TCGASubtype data.")
  nodes_TCGASubtype <- feather::read_feather(apply_path("nodes_TCGASubtype.feather")) %>%
    dplyr::distinct(hgnc = Node, tag = Group, score = UpBinRatio) %>%
    dplyr::left_join(
      current_pool %>% dplyr::tbl("genes") %>%
        dplyr::select(entrez, hgnc) %>%
        dplyr::mutate_at(dplyr::vars(entrez), as.numeric) %>%
        dplyr::as_tibble(),
      by = "hgnc"
    )

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
