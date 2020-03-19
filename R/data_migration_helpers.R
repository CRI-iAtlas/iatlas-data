get_gene_ids <- function() {
  iatlas.data::result_cached(
    "gene_ids",
    feather::read_feather("feather_files/gene_ids.feather") %>% dplyr::as_tibble())
}

synapse_feather_id_to_tbl <- function(id) {
  id %>%
    .GlobalEnv$synapse$get() %>%
    purrr::pluck("path") %>%
    feather::read_feather() %>%
    dplyr::as_tibble()
}
