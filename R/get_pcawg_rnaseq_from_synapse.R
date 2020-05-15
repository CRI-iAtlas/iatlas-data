get_pcawg_rnaseq_from_synapse <- function() {
  iatlas.data::create_global_synapse_connection()
  # Get the data from Synapse.
  pcawg_rnaseq_synapse <- "syn21785590" %>%
      .GlobalEnv$synapse$get() %>%
      .$path %>%
      read.csv(stringsAsFactors = F, header = T, sep = "\t", check.names = F) %>%
      dplyr::as_tibble() %>%
      dplyr::rename(hgnc = gene)
  # Move aliquot_id columns to rows.
  pcawg_rnaseq_synapse <- pcawg_rnaseq_synapse %>%
    tidyr::pivot_longer(-hgnc, values_to = "rna_seq_expr", names_to = "sample")
  # Inner join on hgnc to get entrez values (inner join to remove hgncs with no entrez id).
  pcawg_rnaseq_synapse <- pcawg_rnaseq_synapse %>% dplyr::inner_join(iatlas.data::get_gene_ids(), by = "hgnc")
  pcawg_rnaseq_synapse <- pcawg_rnaseq_synapse %>% dplyr::distinct(entrez, hgnc, sample, rna_seq_expr)
  return(pcawg_rnaseq_synapse)
}

