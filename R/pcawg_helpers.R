pcawg_synapse_id               <- "syn18234582"

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
    "syn18234560" %>%
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

get_pcawg_features_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_features",
    dplyr::tribble(
      ~name,                              ~display,                ~unit,   ~class,
      "mcpcounter_t_cells",               "T cells",               "score", "mcpcounter",
      "mcpcounter_cd8_t_cells",           "DC8 T Cells",           "score", "mcpcounter",
      "mcpcounter_cytotoxic_lymphocytes", "Cytotoxic Lymphocytes", "score", "mcpcounter",
      "mcpcounter_nk_cells",              "NK cells",              "score", "mcpcounter",
      "mcpcounter_b_lineage",             "B Lineage",             "score", "mcpcounter"
    )
  )
}

get_pcawg_tag_values_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_tag_values",
    "syn20717211" %>%
      .GlobalEnv$synapse$get() %>%
      purrr::pluck("path") %>%
      read.table(stringsAsFactors = F, header = T, sep = "\t") %>%
      dplyr::as_tibble() %>%
      dplyr::inner_join(
        get_pcawg_samples_synapse_cached(),
        by = c("sample" = "aliquot_id")
      ) %>%
      dplyr::select(sample = icgc_donor_id, subtype, dcc_project_code) %>%
      dplyr::mutate(dataset = "PCAWG") %>%
      tidyr::pivot_longer(-sample, values_to = "tag") %>%
      dplyr::select(-name)
  )
}

