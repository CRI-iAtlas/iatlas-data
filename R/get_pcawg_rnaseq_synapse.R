get_pcawg_rnaseq_synapse <- function(){
  name_trans_tbl <- iatlas.data::get_pcawg_samples_synapse_cached() %>%
    dplyr::select(aliquot_id, sample = icgc_donor_id)
  # Get the data from Synapse.
  pcawg_rnaseq_synapse <- "syn18268621" %>%
    .GlobalEnv$synapse$get() %>%
    .$path %>%
    read.csv(stringsAsFactors = F, header = T, sep = "\t", check.names = F) %>%
    dplyr::as_tibble() %>%
    dplyr::rename(hgnc = hugo)
  # Move aliquot_id columns to rows.
  pcawg_rnaseq_synapse <- pcawg_rnaseq_synapse %>%
    tidyr::pivot_longer(-hgnc, values_to = "rna_seq_expr", names_to = "aliquot_id")
  # Inner join on hgnc to get entrez values (inner join to remove hgncs with no entrez id).
  pcawg_rnaseq_synapse <- pcawg_rnaseq_synapse %>% dplyr::inner_join(iatlas.data::get_gene_ids(), by = "hgnc")
  # Inner join on aliquot_id to get sample values (inner join to remove values not in the samples).
  pcawg_rnaseq_synapse <- pcawg_rnaseq_synapse %>%
    dplyr::inner_join(name_trans_tbl, by = "aliquot_id")
  pcawg_rnaseq_synapse <- pcawg_rnaseq_synapse %>% dplyr::distinct(entrez, hgnc, sample, rna_seq_expr)
  return(pcawg_rnaseq_synapse)
}

