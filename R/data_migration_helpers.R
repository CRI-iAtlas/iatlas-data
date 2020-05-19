get_gene_ids <- function() {
  iatlas.data::result_cached(
    "gene_ids",
    feather::read_feather("feather_files/genes/master_gene_ids.feather") %>% dplyr::as_tibble())
}

get_known_gene_resolutions <- function() {
  iatlas.data::result_cached(
    "known_gene_resolutions",
    feather::read_feather("feather_files/known_gene_resolutions.feather") %>% dplyr::as_tibble())
}

resolve_hgnc_conflicts <- function(genes) {
  genes %>% dplyr::left_join(get_known_gene_resolutions(), by = c("entrez")) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(hgnc = ifelse(identical(hgnc, alias), official, hgnc)) %>%
    dplyr::select(-c(alias, official))
}

synapse_feather_id_to_tbl <- function(id) {
  id %>%
    .GlobalEnv$synapse$get() %>%
    purrr::pluck("path") %>%
    feather::read_feather() %>%
    dplyr::as_tibble()
}
