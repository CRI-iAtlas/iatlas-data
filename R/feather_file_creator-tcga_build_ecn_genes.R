tcga_build_ecn_genes <- function() {

  # TODO: figure out where
  node_names <- "syn21783989" %>%
    .GlobalEnv$synapse$get() %>%
    purrr::pluck("path") %>%
    feather::read_feather(.) %>%
    dplyr::as_tibble() %>%
    dplyr::select(
      "node_type" = "Type",
      "hgnc" = "Obj",
      "display" = "FriendlyName"
    ) %>%
    tibble::add_column(type = "extra_cellular_network") %>%
    dplyr::left_join(
      iatlas.data::get_gene_ids() %>%
        dplyr::mutate_at(dplyr::vars(entrez), as.numeric),
      by = "hgnc"
      )

  iatlas.data::synapse_store_feather_file(
    node_names,
    "ecn_genes.feather",
    "syn22123343"
  )

  ### Clean up ###
  cat("Cleaned up.", fill = TRUE)
  gc()
}
