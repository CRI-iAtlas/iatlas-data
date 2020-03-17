get_pcawg_fature_values_synapse <- function(){
  dplyr::bind_rows(
    get_pcawg_cibersort_synapse(),
    get_pcawg_mcpcounter_synapse(),
    get_pcawg_mitcr_synapse()
  ) %>%
    tidyr::drop_na()
}

get_pcawg_cibersort_synapse <- function(){
  names_tbl <- get_pcawg_samples_synapse_cached()
  paste0(
      "select id, ICGC_Donor_ID, ICGC_Specimen_ID from syn20583414 ",
      "where method = 'cibersort'"
    ) %>%
    .GlobalEnv$synapse$tableQuery(includeRowIdAndRowVersion = F) %>%
    .$filepath %>%
    read.csv(stringsAsFactors = F) %>%
    dplyr::as_tibble() %>%
    dplyr::filter(ICGC_Specimen_ID %in% names_tbl$icgc_specimen_id) %>%
    dplyr::mutate(tbl = purrr::map(id, synapse_id_to_tbl)) %>%
    dplyr::select(ICGC_Donor_ID, tbl) %>%
    tidyr::unnest(cols = tbl) %>%
    dplyr::select(-sample) %>%
    dplyr::rename(sample = ICGC_Donor_ID) %>%
    tidyr::pivot_longer(-sample, values_to = "value", names_to = "feature") %>%
    dplyr::mutate(feature = stringr::str_remove_all(feature, ".Relative")) %>%
    dplyr::mutate(feature = stringr::str_replace_all(feature, "\\.", "_")) %>%
    dplyr::mutate(feature = stringr::str_replace_all(feature, "__", "_"))
}

get_pcawg_mcpcounter_synapse <- function(){
  names_tbl <- get_pcawg_samples_synapse_cached()
  paste0(
      "select id, ICGC_Donor_ID, ICGC_Specimen_ID from syn20583414 ",
      "where method = 'mcpcounter'"
    ) %>%
    .GlobalEnv$synapse$tableQuery(includeRowIdAndRowVersion = F) %>%
    .$filepath %>%
    read.csv(stringsAsFactors = F) %>%
    dplyr::as_tibble() %>%
    dplyr::filter(ICGC_Specimen_ID %in% names_tbl$icgc_specimen_id) %>%
    dplyr::mutate(tbl = purrr::map(id, synapse_id_to_tbl)) %>%
    dplyr::select(ICGC_Donor_ID, tbl) %>%
    tidyr::unnest(cols = tbl) %>%
    dplyr::select(-sample) %>%
    dplyr::rename(sample = ICGC_Donor_ID) %>%
    tidyr::pivot_longer(-sample, values_to = "value", names_to = "feature") %>%
    dplyr::mutate(feature = tolower(feature)) %>%
    dplyr::mutate(feature = stringr::str_replace_all(feature, " ", "_")) %>%
    dplyr::mutate(feature = stringr::str_replace_all(feature, "\\.", "_")) %>%
    dplyr::mutate(feature = paste0("mcpcounter_", feature))
}

get_pcawg_mitcr_synapse <- function(){
  names_tbl <- get_pcawg_samples_synapse_cached() %>%
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

synapse_id_to_tbl <- function(id){
  id %>%
    .GlobalEnv$synapse$get() %>%
    purrr::pluck("path") %>%
    read.csv(sep = "\t", stringsAsFactors = F) %>%
    dplyr::as_tibble()
}

synapse_id_to_tbl2 <- function(id){
  id %>%
    .GlobalEnv$synapse$get() %>%
    purrr::pluck("path") %>%
    jsonlite::fromJSON() %>%
    dplyr::as_tibble()
}
