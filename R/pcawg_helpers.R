pcawg_synapse_id               <- "syn18234582"
tcga_sample_synpse_id          <- "syn18234560"
pcawg_rna_synapse_id           <- "syn18268621"

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

get_pcawg_cibersort_values_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_cibersort",
    iatlas.data::get_pcawg_cibersort_synapse()
  )
}

get_pcawg_mcpcounter_values_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_mcpcounter",
    iatlas.data::get_pcawg_mcpcounter_synapse()
  )
}

get_pcawg_mitcr_values_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_mitcr",
    iatlas.data::get_pcawg_mitcr_synapse()
  )
}

get_pcawg_feature_values_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_feature_values",
    iatlas.data::get_pcawg_fature_values_synapse()
  )
}



