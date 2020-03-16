get_pcawg_cibersort_synapse <- function(){
  names_tbl <- get_pcawg_samples_synapse_cached()
  deconvolution_table_synapse_id %>%
    paste0(
      "select id, ICGC_Donor_ID, ICGC_Specimen_ID from ",
      .,
      " where method = 'cibersort'"
    ) %>%
    .GlobalEnv$synapse$tableQuery(includeRowIdAndRowVersion = F) %>%
    .$filepath %>%
    data.table::fread() %>%
    dplyr::as_tibble() %>%
    dplyr::filter(ICGC_Specimen_ID %in% names_tbl$icgc_specimen_id) %>%
    dplyr::mutate(tbl = purrr::map(id, synapse_id_to_tbl)) %>%
    dplyr::select(ICGC_Donor_ID, tbl) %>%
    tidyr::unnest(cols = tbl) %>%
    dplyr::select(-sample) %>%
    dplyr::rename(sample = ICGC_Donor_ID) %>%
    tidyr::pivot_longer(-sample, values_to = "value", names_to = "feature")
}

get_pcawg_mcpcounter_synapse <- function(){
  names_tbl <- get_pcawg_samples_synapse_cached()
  deconvolution_table_synapse_id %>%
    paste0(
      "select id, ICGC_Donor_ID, ICGC_Specimen_ID from ",
      .,
      " where method = 'mcpcounter'"
    ) %>%
    .GlobalEnv$synapse$tableQuery(includeRowIdAndRowVersion = F) %>%
    .$filepath %>%
    data.table::fread() %>%
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
    dplyr::mutate(feature = paste0("epic_", feature))
}

synapse_id_to_tbl <- function(id){
  id %>%
    .GlobalEnv$synapse$get() %>%
    purrr::pluck("path") %>%
    data.table::fread() %>%
    dplyr::as_tibble()
}
