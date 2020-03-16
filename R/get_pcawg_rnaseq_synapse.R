get_pcawg_rnaseq_synapse <- function(){
  gene_trans_tbl <- feather::read_feather("feather_files/gene_ids.feather")
  name_trans_tbl <- get_pcawg_samples_synapse_cached()
  pcawg_rna_synapse_id %>%
    .GlobalEnv$synapse$get() %>%
    .$path %>%
    data.table::fread() %>%
    dplyr::as_tibble() %>%
    dplyr::inner_join(gene_trans_tbl, by = c("hugo" = "hgnc")) %>%
    dplyr::select(-hugo) %>%
    tidyr::pivot_longer(
      .,
      -entrez,
      values_to = "rna_seq_expr",
      names_to = "aliquot_id"
    ) %>%
    dplyr::inner_join(name_trans_tbl, by = "aliquot_id") %>%
    dplyr::select(gene = entrez, sample = icgc_donor_id, rna_seq_expr)
}

