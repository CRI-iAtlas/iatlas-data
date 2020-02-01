get_ecn_nodes_by_study <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_ecn_nodes_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_ecn_nodes <- function(study) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    cat(crayon::magenta(paste0("Get ecn nodes by `", study, "`")), fill = TRUE)

    cat_ecn_nodes_status("Get the initial values from the nodes table.")
    nodes <- current_pool %>% dplyr::tbl("nodes")

    cat_ecn_nodes_status("Get the tag ids for the nodes from the nodes_to_tags table.")
    nodes <- nodes %>% dplyr::right_join(
      current_pool %>% dplyr::tbl("nodes_to_tags"),
      by = c("id" = "node_id")
    )

    cat_ecn_nodes_status("Get the tag names for the nodes by tag id.")
    nodes <- nodes %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, tag = name),
      by = c("tag_id" = "id")
    )

    cat_ecn_nodes_status("Get tag ids related to the tags :)")
    nodes <- nodes %>% dplyr::right_join(
      current_pool %>% dplyr::tbl("tags_to_tags"),
      by = "tag_id"
    )

    cat_ecn_nodes_status("Get the related tag names for the nodes by related tag id.")
    nodes <- nodes %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("tags") %>%
        dplyr::select(id, related_tag = name),
      by = c("related_tag_id" = "id")
    )

    cat_ecn_nodes_status("Filter the data set to tags related to the passed study.")
    nodes <- nodes %>% dplyr::filter(tag == study | related_tag == study)

    cat_ecn_nodes_status("Get the genes related to the nodes.")
    nodes <- nodes %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("genes") %>%
        dplyr::select(id, entrez, hgnc),
      by = c("gene_id" = "id")
    )

    cat_ecn_nodes_status("Get the features related to the nodes.")
    nodes <- nodes %>% dplyr::left_join(
      current_pool %>% dplyr::tbl("features") %>%
        dplyr::select(id, feature = name),
      by = c("feature_id" = "id")
    )

    cat_ecn_nodes_status("Clean up the data set.")
    nodes <- nodes %>%
      dplyr::distinct(node_id, entrez, hgnc, feature, tag, score) %>%
      dplyr::arrange(node_id, entrez, hgnc, feature, tag, score)

    cat_ecn_nodes_status("Execute the query and return a tibble.")
    nodes <- nodes %>% dplyr::as_tibble()

    pool::poolReturn(current_pool)

    return(nodes)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_nodes <- "TCGA_Study" %>%
    get_ecn_nodes %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/nodes_to_tags/tcga_study_nodes.feather"))

  .GlobalEnv$tcga_subtype_nodes <- "TCGA_Subtype" %>%
    get_ecn_nodes %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/nodes_to_tags/tcga_subtype_nodes.feather"))

  .GlobalEnv$immune_subtype_nodes <- "Immune_Subtype" %>%
    get_ecn_nodes %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/nodes_to_tags/immune_subtype_nodes.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  # rm(tcga_study_nodes, pos = ".GlobalEnv")
  # rm(tcga_subtype_nodes, pos = ".GlobalEnv")
  # rm(immune_subtype_nodes, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
