get_gene_ids <- function() {
  iatlas.data::result_cached(
    "gene_ids",
    feather::read_feather("feather_files/gene_ids.feather") %>% dplyr::as_tibble())
}
