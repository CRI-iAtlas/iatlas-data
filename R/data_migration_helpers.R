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

get_master_gene_ids_cached <- function() {
  iatlas.data::result_cached(
    "gene_ids",
    {
      human_gene_ids <- iatlas.data::get_human_gene_ids_cached()
      gene_ids <- iatlas.data::get_gene_ids()
      gene_ids_unique_entrez <- gene_ids %>%
        dplyr::select(-hgnc) %>%
        dplyr::left_join(human_gene_ids, by = "entrez") %>%
        dplyr::filter(is.na(hgnc)) %>%
        dplyr::select(-hgnc) %>%
        dplyr::left_join(gene_ids, by = "entrez")
      human_gene_ids %>% dplyr::bind_rows(gene_ids_unique_entrez)
    }
  )
}

get_rna_seq_expr_matrix <- function(genes) result_cached("rna_seq_expr_matrix", iatlas.data::load_rna_seq_expr(paste0(getwd(), "/feather_files"), genes))

synapse_feather_id_to_tbl <- function(id) {
  id %>%
    .GlobalEnv$synapse$get() %>%
    purrr::pluck("path") %>%
    feather::read_feather() %>%
    dplyr::as_tibble()
}
