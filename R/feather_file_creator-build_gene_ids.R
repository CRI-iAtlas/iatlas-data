build_gene_ids <- function() {
  all_gene_ids <- .GlobalEnv$synapse$get("syn4976369") %>%
    purrr::pluck("path") %>%
    readr::read_tsv(.)
  gene_ids <- all_gene_ids %>%
    dplyr::as_tibble() %>%
    dplyr::select(gene_id) %>%
    tidyr::separate(gene_id, c("hgnc", "entrez"), sep = "[|]") %>%
    dplyr::mutate(
      hgnc = ifelse(hgnc == "?", NA, hgnc),
      entrez = ifelse(entrez == "?", NA, entrez)
    ) %>%
    dplyr::mutate_at(dplyr::vars(entrez), as.numeric)

  gene_ids <- gene_ids %>% dplyr::filter(entrez != 728661)

  gene_ids <- gene_ids %>% dplyr::add_row(entrez = 728661, hgnc = "SLC35E2B")

  feather::write_feather(gene_ids, "tcga_gene_ids.feather")
  iatlas.data::synapse_store_file("tcga_gene_ids.feather", "syn22123343")
  file.remove("tcga_gene_ids.feather")
}
