get_gene_ids <- function() {
  iatlas.data::result_cached(
    "gene_ids",
    feather::read_feather("feather_files/gene_ids.feather") %>% dplyr::as_tibble())
}

get_human_gene_ids <- function() {
  feather_file <- paste0(getwd(), "/feather_files/human_gene_ids.feather")
  if (!file.exists(feather_file)) {
    cat(crayon::blue("Reading human_gene_ids from Synapse."), fill = TRUE)
    iatlas.data::create_global_synapse_connection()
    on.exit(iatlas.data::synapse_logout())
    return(
      "syn21788372" %>%
        .GlobalEnv$synapse$get() %>%
        .$path %>%
        read.csv(stringsAsFactors = F, header = T, sep = "\t", check.names = F) %>%
        dplyr::as_tibble() %>%
        feather::write_feather(feather_file)
    )
  }
  return(feather::read_feather(feather_file))
}

get_human_gene_ids_cached <- function() {
  iatlas.data::result_cached("human_gene_ids", get_human_gene_ids()) %>% dplyr::distinct(entrez, hgnc)
}

synapse_feather_id_to_tbl <- function(id) {
  id %>%
    .GlobalEnv$synapse$get() %>%
    purrr::pluck("path") %>%
    feather::read_feather() %>%
    dplyr::as_tibble()
}
