pcawg_synapse_id      <- "syn18234582"
tcga_sample_synpse_id <- "syn18234560"
pcawg_rna_synapse_id  <- "syn18268621"

get_all_pcawg_samples_synapse_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "all_pcawg_samples_synapse",
    pcawg_synapse_id %>%
      .GlobalEnv$synapse$get() %>%
      .$path %>%
      read.csv(sep = "\t", stringsAsFactors = F)
  )
}

get_tcga_samples_synapse_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "tcga_sample_ids",
    tcga_sample_synpse_id %>%
      .GlobalEnv$synapse$get() %>%
      .$path %>%
      read.csv(sep = "\t", stringsAsFactors = F) %>%
      dplyr::pull(icgc_sample_id)
  )
}

get_pcawg_samples_synapse_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_samples",
    iatlas.data::get_pcawg_samples_synapse()
  )
}

get_pcawg_rnaseq_synapse_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_rnaseq",
    iatlas.data::get_pcawg_rnaseq_synapse()
  )
}



