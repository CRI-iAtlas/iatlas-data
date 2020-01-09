all_gene_ids <- read.table("tsv_files/EBPlusPlusAdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.tsv", sep = '\t', header = TRUE)
gene_ids <- all_gene_ids %>%
  dplyr::as_tibble() %>%
  dplyr::select(gene_id) %>%
  tidyr::separate(gene_id, c("hgnc", "entrez"), sep = "[|]") %>%
  dplyr::mutate(hgnc = ifelse(hgnc == "?", NA, hgnc), entrez = ifelse(entrez == "?", NA, entrez))

gene_ids %>% feather::write_feather("../feather_files/gene_ids.feather")
