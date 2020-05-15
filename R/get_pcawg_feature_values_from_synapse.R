get_pcawg_feature_values_from_synapse <- function() {
  dplyr::bind_rows(
    iatlas.data::get_pcawg_cibersort_cached(),
    iatlas.data::get_pcawg_mcpcounter_cached(),
    iatlas.data::get_pcawg_epic_cached(),
    iatlas.data::get_pcawg_mitcr_cached()
  ) %>%
    tidyr::drop_na()
}

get_pcawg_cibersort_from_synapse <- function() {
  iatlas.data::create_global_synapse_connection()
  "syn21785667" %>%
    synapse_id_to_tbl() %>%
    tidyr::pivot_longer(., -sample, values_to = "value", names_to = "feature")
}

get_pcawg_mcpcounter_from_synapse <- function() {
  iatlas.data::create_global_synapse_connection()
  "syn21785753" %>%
    synapse_id_to_tbl() %>%
    tidyr::pivot_longer(., -sample, values_to = "value", names_to = "feature")
}

get_pcawg_epic_from_synapse <- function() {
  iatlas.data::create_global_synapse_connection()
  "syn21785736" %>%
    synapse_id_to_tbl() %>%
    tidyr::pivot_longer(., -sample, values_to = "value", names_to = "feature")
}

get_pcawg_mitcr_from_synapse <- function() {
  names_tbl <- get_pcawg_sample_tbl_cached() %>%
    dplyr::select(icgc_sample_id, icgc_donor_id)
  "select id from syn20693185" %>%
    .GlobalEnv$synapse$tableQuery(includeRowIdAndRowVersion = F) %>%
    .$filepath %>%
    read.csv(stringsAsFactors = F) %>%
    dplyr::as_tibble() %>%
    dplyr::mutate(tbl = purrr::map(id, synapse_id_to_tbl2)) %>%
    dplyr::select(tbl) %>%
    tidyr::unnest(cols = tbl) %>%
    dplyr::inner_join(names_tbl, by = c("sample" = "icgc_sample_id")) %>%
    dplyr::select(-sample) %>%
    dplyr::select(
      sample = icgc_donor_id, TCR_Shannon, TCR_Richness, TCR_Evenness
    ) %>%
    tidyr::pivot_longer(-sample, values_to = "value", names_to = "feature")
}

synapse_id_to_tbl <- function(id) {
  id %>%
    .GlobalEnv$synapse$get() %>%
    purrr::pluck("path") %>%
    read.csv(sep = "\t", stringsAsFactors = F) %>%
    dplyr::as_tibble()
}

synapse_id_to_tbl2 <- function(id) {
  id %>%
    .GlobalEnv$synapse$get() %>%
    purrr::pluck("path") %>%
    jsonlite::fromJSON() %>%
    dplyr::as_tibble()
}
