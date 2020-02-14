build_gene_ids <- function() {
  all_gene_ids <- feather::read_feather(paste0(getwd(), "/feather_files/EBPlusPlusAdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.feather"))
  gene_ids <- all_gene_ids %>%
    dplyr::as_tibble() %>%
    dplyr::select(gene_id) %>%
    tidyr::separate(gene_id, c("hgnc", "entrez"), sep = "[|]") %>%
    dplyr::mutate(hgnc = ifelse(hgnc == "?", NA, hgnc), entrez = ifelse(entrez == "?", NA, entrez))

  gene_ids %>% feather::write_feather(paste0(getwd(), "/feather_files/gene_ids.feather"))
}
