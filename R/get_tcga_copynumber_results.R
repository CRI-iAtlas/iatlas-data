get_tcga_copynumber_results <- function() {
  iatlas.data::create_global_synapse_connection()
  on.exit(iatlas.data::synapse_logout())
  paths <- c("syn21781426", "syn21781395", "syn21781409") %>%
    purrr::map(.GlobalEnv$synapse$get) %>%
    purrr::map(purrr::pluck, "path")

  purrr::walk(paths, load)
  for (path in paths) {
    load(path)
  }

  tbl <-
    list(immunetable, studytable, subtypetable) %>%
    dplyr::bind_rows() %>%
    dplyr::select(
      tag = Group,
      hgnc = Gene,
      feature = Metric,
      direction = Direction,
      mean_normal = Mean_Normal,
      mean_cnv = Mean_CNV,
      t_stat = T_stat,
      p_value = Pvalue,
      log10_p_value = Neg_log10_pvalue
    ) %>%
    dplyr::mutate(feature = stringr::str_replace_all(feature, "\\.", "_"))

  human_gene_ids <- iatlas.data::get_human_gene_ids_cached()

  # Convert HGNC to Entrez ---------------------------------------------------
  tbl <- tbl %>% dplyr::left_join(iatlas.data::get_human_gene_ids_cached(), by = "hgnc")
  with_entrez <- tbl %>% dplyr::filter(!is.na(entrez))
  no_entrez <- tbl %>% dplyr::filter(is.na(entrez))
  have_entrez <- no_entrez %>%
    dplyr::select(-entrez) %>%
    dplyr::inner_join(iatlas.data::get_gene_ids(), by = "hgnc")
  tbl <- with_entrez %>% dplyr::bind_rows(have_entrez) %>%
    dplyr::mutate_at(dplyr::vars(entrez), as.numeric)

  # Clean up the data ---------------------------------------------------
  tbl <- tbl %>%
    dplyr::distinct(entrez, feature, tag, direction, mean_normal, mean_cnv, p_value, log10_p_value, t_stat) %>%
    dplyr::arrange(entrez, feature, tag, direction)

  rm(immunetable)
  rm(studytable)
  rm(subtypetable)
  gc()
  return(tbl)
}
