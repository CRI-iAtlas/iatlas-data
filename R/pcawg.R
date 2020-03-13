create_global_synapse_connection()

pcawg_synapse_id    <- "syn18234582"
tcga_sample_id      <- "syn18234560"
rna_id              <- "syn18134933"

icgc_tbl <- pcawg_synapse_id %>%
  synapser::synGet() %>%
  .$path %>%
  readr::read_tsv()

tcga_sample_ids <- tcga_sample_id %>%
  synapser::synGet() %>%
  .$path %>%
  readr::read_tsv() %>%
  dplyr::pull(icgc_sample_id)

pcawg_tbl <- pcawg_synapse_id %>%
  synapser::synGet() %>%
  .$path %>%
  readr::read_tsv() %>%
  dplyr::filter(donor_wgs_exclusion_white_gray == "Whitelist") %>%
  dplyr::filter(library_strategy == "RNA-Seq") %>%
  dplyr::filter(!aliquot_id %in% tcga_sample_ids) %>%
  dplyr::filter(!stringr::str_detect(dcc_specimen_type, "Normal")) %>%
  dplyr::filter(!stringr::str_detect(dcc_specimen_type, "Metastatic")) %>%
  dplyr::mutate(dcc_specimen_type = forcats::fct_relevel(
    dcc_specimen_type,
    levels = c(
      "Primary tumour - solid tissue",
      "Primary tumour - other",
      "Recurrent tumour - solid tissue",
      "Recurrent tumour - other"
    )
  )) %>%
  dplyr::group_by(icgc_donor_id) %>%
  dplyr::arrange(dcc_specimen_type) %>%
  dplyr::slice(1) %>%
  dplyr::ungroup()

#genes to samples

rna_tbl <- rna_id %>%
  synapser::synGet() %>%
  .$path %>%
  data.table::fread() %>%
  dplyr::as_tibble()

rna_tbl2 <- rna_tbl %>%
  dplyr::select(dplyr::one_of(c("feature", pcawg_tbl$aliquot_id))) %>%
  tidyr::pivot_longer(
    -feature,
    names_to = "sample_name",
    values_to = "rna_seq_expr"
  )
