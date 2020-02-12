build_ecn_genes <- function() {
  gene_ids <- feather::read_feather(
    paste0(getwd(), "/feather_files/gene_ids.feather")
  ) %>%
    dplyr::as_tibble()

  node_names <- feather::read_feather(
    paste0(getwd(), "/feather_files/network_node_label_friendly.feather")
  ) %>%
    dplyr::as_tibble()

  node_names <- node_names %>%
    dplyr::rename(node_type = Type) %>%
    dplyr::rename(hgnc = Obj) %>%
    dplyr::rename(display = FriendlyName) %>%
    tibble::add_column(type = "extra_cellular_network")

  node_names <- node_names %>%
    dplyr::inner_join(
      gene_ids %>% dplyr::mutate_at(dplyr::vars(entrez), as.numeric),
      by = "hgnc"
    )

  node_names %>% feather::write_feather(paste0(getwd(), "/feather_files/ecn_genes.feather"))

  ### Clean up ###
  cat("Cleaned up.", fill = TRUE)
  gc()
}
