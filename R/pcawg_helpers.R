get_pcawg_sample_tbl_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_sample_tbl",
    "syn21785582" %>%
      .GlobalEnv$synapse$get() %>%
      .$path %>%
      read.csv(sep = "\t", stringsAsFactors = F) %>%
      dplyr::as_tibble()
  )
}

get_pcawg_samples_cached <- function(){
  iatlas.data::result_cached(
    "pcawg_sample_tbl",
    get_pcawg_sample_tbl_cached() %>%
      dplyr::select(sample = icgc_donor_id) %>%
      plyr::mutate(patient = sample)
  )
}

get_pcawg_rnaseq_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_rnaseq",
    iatlas.data::get_pcawg_rnaseq_from_synapse()
  )
}

get_pcawg_cibersort_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_cibersort",
    iatlas.data::get_pcawg_cibersort_from_synapse()
  )
}

get_pcawg_mcpcounter_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_mcpcounter",
    iatlas.data::get_pcawg_mcpcounter_from_synapse()
  )
}

get_pcawg_epic_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_epic",
    iatlas.data::get_pcawg_epic_from_synapse()
  )
}

get_pcawg_mitcr_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_mitcr",
    iatlas.data::get_pcawg_mitcr_from_synapse()
  )
}

get_pcawg_feature_values_cached <- function(){
  iatlas.data::result_cached(
    "pcawg_feature_values",
    iatlas.data::get_pcawg_feature_values_from_synapse()
  )
}

get_pcawg_features_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "pcawg_features",
    list(
      get_pcawg_epic_cached(),
      get_pcawg_mcpcounter_cached()
      ) %>%
      dplyr::bind_rows() %>%
      dplyr::select(name = feature) %>%
      dplyr::distinct() %>%
      dplyr::mutate(
        display = stringr::str_replace_all(name, "_", " "),
        class = stringr::str_match(name,  "^(\\w+?)_")[,2],
        unit = dplyr::if_else(class == "MCPcounter", "Score", "Fraction")
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
        get_pcawg_sample_tbl_cached(),
        by = c("sample" = "aliquot_id")
      ) %>%
      dplyr::select(sample = icgc_donor_id, subtype, dcc_project_code) %>%
      dplyr::mutate(dataset = "PCAWG") %>%
      tidyr::pivot_longer(-sample, values_to = "tag") %>%
      dplyr::select(-name)
  )
}

