get_ecn_nodes_by_study <- function() {
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

  # nodes <- iatlas.data::read_iatlas_data_file("feather_files", "nodes") %>%
  #   dplyr::distinct(hgnc = Node, tag.01 = Group, tag.02 = Immune, score = UpBinRatio) %>%
  #   dplyr::arrange(hgnc, tag.01, tag.02, score)
  #
  # get_ecn_nodes <- function(study) {
  #   current_pool <- pool::poolCheckout(.GlobalEnv$pool)
  #
  #   cat(crayon::magenta(paste0("Get ecn nodes by `", study, "`")), fill = TRUE)
  #
  #   cat_ecn_nodes_status("Get the tag names for the nodes by tag name.")
  #   study_nodes <- nodes %>% dplyr::left_join(
  #     current_pool %>% dplyr::tbl("tags") %>%
  #       dplyr::select(tag.01_id = id, tag.01_name = name) %>%
  #       dplyr::as_tibble(),
  #     by = c("tag.01" = "tag.01_name")
  #   ) %>% dplyr::left_join(
  #     current_pool %>% dplyr::tbl("tags") %>%
  #       dplyr::select(tag.02_id = id, tag.02_name = name) %>%
  #       dplyr::as_tibble(),
  #     by = c("tag.02" = "tag.02_name")
  #   )
  #
  #   cat_ecn_nodes_status("Get tag ids related to the tags :)")
  #   study_nodes <- study_nodes %>% dplyr::full_join(
  #     current_pool %>% dplyr::tbl("tags_to_tags") %>%
  #       dplyr::select(tag.01_id = tag_id, tag.01_rel_id = related_tag_id) %>%
  #       dplyr::as_tibble(),
  #     by = "tag.01_id"
  #   ) %>% dplyr::full_join(
  #     current_pool %>% dplyr::tbl("tags_to_tags") %>%
  #       dplyr::select(tag.02_id = tag_id, tag.02_rel_id = related_tag_id) %>%
  #       dplyr::as_tibble(),
  #     by = "tag.02_id"
  #   )
  #
  #   cat_ecn_nodes_status("Get the related tag names for the nodes by related tag id.")
  #   study_nodes <- study_nodes %>% dplyr::left_join(
  #     current_pool %>% dplyr::tbl("tags") %>%
  #       dplyr::select(tag.01_rel_id = id, tag.01_rel_name = name) %>%
  #       dplyr::as_tibble(),
  #     by = "tag.01_rel_id"
  #   ) %>% dplyr::left_join(
  #     current_pool %>% dplyr::tbl("tags") %>%
  #       dplyr::select(tag.02_rel_id = id, tag.02_rel_name = name) %>%
  #       dplyr::as_tibble(),
  #     by = "tag.02_rel_id"
  #   )
  #
  #   cat_ecn_nodes_status("Filter the data set to tags related to the passed study.")
  #   study_nodes <- study_nodes %>% dplyr::filter(
  #     tag.01 == study | tag.02 == study | tag.01_rel_name == study |tag.02_rel_name == study
  #   )
  #
  #   cat_ecn_nodes_status("Get the genes related to the nodes.")
  #   study_nodes <- study_nodes %>% dplyr::left_join(
  #     current_pool %>% dplyr::tbl("genes") %>%
  #       dplyr::select(entrez, hgnc) %>%
  #       dplyr::as_tibble(),
  #     by = "hgnc"
  #   )
  #
  #   cat_ecn_nodes_status("Get the features related to the nodes.")
  #   study_nodes <- study_nodes %>%
  #     tibble::add_column(feature = NA %>% as.character)
  #
  #   cat_ecn_nodes_status("Clean up the data set.")
  #   study_nodes <- study_nodes %>%
  #     dplyr::distinct(entrez, hgnc, feature, tag.01, tag.02, score) %>%
  #     dplyr::arrange(entrez, hgnc, feature, tag.01, tag.02, score)
  #
  #   # cat_ecn_nodes_status("Execute the query and return a tibble.")
  #   # study_nodes <- study_nodes %>% dplyr::as_tibble()
  #
  #   pool::poolReturn(current_pool)
  #
  #   return(study_nodes)
  # }
  #
  # # Setting these to the GlobalEnv just for development purposes.
  # .GlobalEnv$tcga_study_nodes <- "TCGA_Study" %>%
  #   get_ecn_nodes %>%
  #   feather::write_feather(paste0(getwd(), "/feather_files/relationships/nodes_to_tags/tcga_study_nodes.feather"))
  #
  # .GlobalEnv$tcga_subtype_nodes <- "TCGA_Subtype" %>%
  #   get_ecn_nodes %>%
  #   feather::write_feather(paste0(getwd(), "/feather_files/relationships/nodes_to_tags/tcga_subtype_nodes.feather"))
  #
  # .GlobalEnv$immune_subtype_nodes <- "Immune_Subtype" %>%
  #   get_ecn_nodes %>%
  #   feather::write_feather(paste0(getwd(), "/feather_files/relationships/nodes_to_tags/immune_subtype_nodes.feather"))

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
  # rm(tcga_study_nodes, pos = ".GlobalEnv")
  # rm(tcga_subtype_nodes, pos = ".GlobalEnv")
  # rm(immune_subtype_nodes, pos = ".GlobalEnv")
  rm(nodes_TCGAImmune, pos = ".GlobalEnv")
  rm(nodes_TCGAStudy_Immune, pos = ".GlobalEnv")
  rm(nodes_TCGAStudy, pos = ".GlobalEnv")
  rm(nodes_TCGASubtype, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
