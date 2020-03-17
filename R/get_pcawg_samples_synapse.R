get_pcawg_samples_synapse <- function(){
  pcawg_synapse_id %>%
    .GlobalEnv$synapse$get() %>%
    .$path %>%
    read.csv(sep = "\t", stringsAsFactors = F) %>%
    dplyr::as_tibble() %>%
    dplyr::filter(donor_wgs_exclusion_white_gray == "Whitelist") %>%
    dplyr::filter(library_strategy == "RNA-Seq") %>%
    dplyr::filter(!aliquot_id %in% get_tcga_samples_synapse_cached()) %>%
    dplyr::filter(!stringr::str_detect(dcc_specimen_type, "Normal")) %>%
    dplyr::filter(!stringr::str_detect(dcc_specimen_type, "Metastatic")) %>%
    dplyr::mutate(dcc_specimen_type = factor(
      dcc_specimen_type,
      levels = c(
        "Primary tumour - solid tissue",
        "Primary tumour",
        "Primary tumour - blood derived (bone marrow)",
        "Primary tumour - blood derived (peripheral blood)",
        "Primary tumour - lymph node",
        "Primary tumour - other",
        "Recurrent tumour - solid tissue",
        "Recurrent tumour - other"
      )
    )) %>%
    dplyr::group_by(icgc_donor_id) %>%
    dplyr::arrange(dcc_specimen_type) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup()
}

