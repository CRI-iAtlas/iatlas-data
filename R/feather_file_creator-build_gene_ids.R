build_gene_ids <- function() {
  feather_file_folder <- "feather_files"
  all_gene_ids <- iatlas.data::get_rna_seq_expr(feather_file_folder)
  gene_ids <- all_gene_ids %>%
    dplyr::select(gene_id) %>%
    tidyr::separate(gene_id, c("hgnc", "entrez"), sep = "[|]") %>%
    dplyr::mutate(hgnc = ifelse(hgnc == "?", NA, hgnc), entrez = ifelse(entrez == "?", NA, entrez)) %>%
    dplyr::filter(!is.na(hgnc) & !is.na(entrez)) %>%
    dplyr::mutate_at(dplyr::vars(entrez), as.numeric)

  # Fix the split gene "SLC35E2". Should now be "SLC35E2A" = 9906 and "SLC35E2B" = 728661.
  gene_ids <- gene_ids %>% dplyr::mutate(hgnc = ifelse(
    entrez == 9906,
    "SLC35E2A",
    ifelse(entrez == 728661, "SLC35E2B", hgnc)
  ))

  gene_ids %>% feather::write_feather(
    paste0(getwd(), "/", feather_file_folder, "/gene_ids.feather")
  )
}
