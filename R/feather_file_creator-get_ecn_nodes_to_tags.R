get_ecn_nodes_to_tags <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  get_ecn_nodes_to_tags <- function(study) {
    current_pool <- pool::poolCheckout(.GlobalEnv$pool)

    nodes_to_tags <- current_pool %>%
      dplyr::tbl("nodes_to_tags") %>%
      dplyr::as_tibble() %>%
      dplyr::left_join(
        current_pool %>%
          dplyr::tbl("tags") %>%
          dplyr::as_tibble() %>%
          dplyr::select(id, name) %>%
          dplyr::rename_at("name", ~("tag")),
        by = c("tag_id" = "id")
      ) %>%
      dplyr::left_join(
        current_pool %>%
          dplyr::tbl("nodes") %>%
          dplyr::as_tibble(),
        by = c("node_id" = "id")
      ) %>%
      dplyr::left_join(
        current_pool %>%
          dplyr::tbl("node_names") %>%
          dplyr::as_tibble() %>%
          dplyr::rename_at("name", ~("gene")),
        by = c("node_name_id" = "id")
        # ) %>%
        # dplyr::left_join(
        #   current_pool %>%
        #     dplyr::tbl("genes") %>%
        #     dplyr::as_tibble() %>%
        #     dplyr::select(id, entrez),
        #   by = c("gene_id" = "id")
        # ) %>%
        # dplyr::left_join(
        #   current_pool %>%
        #     dplyr::tbl("features") %>%
        #     dplyr::as_tibble() %>%
        #     dplyr::select(id, name) %>%
        #     dplyr::rename_at("name", ~("feature")),
        #   by = c("feature_id" = "id")
      )


    nodes_to_tags %>% merge(nodes_to_tags, by = "node_id")

    pool::poolReturn(current_pool)

    return(nodes_to_tags)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_study_nodes_to_tags <- "TCGA_Study" %>%
    get_ecn_nodes_to_tags %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/nodes_to_tags/tcga_study_nodes_to_tags.feather"))

  .GlobalEnv$tcga_subtype_nodes_to_tags <- "TCGA_Subtype" %>%
    get_ecn_nodes_to_tags %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/nodes_to_tags/tcga_subtype_nodes_to_tags.feather"))

  .GlobalEnv$immune_subtype_nodes_to_tags <- "Immune_Subtype" %>%
    get_ecn_nodes_to_tags %>%
    feather::write_feather(paste0(getwd(), "/feather_files/relationships/nodes_to_tags/immune_subtype_nodes_to_tags.feather"))

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(tcga_study_nodes_to_tags, pos = ".GlobalEnv")
  rm(tcga_subtype_nodes_to_tags, pos = ".GlobalEnv")
  rm(immune_subtype_nodes_to_tags, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
