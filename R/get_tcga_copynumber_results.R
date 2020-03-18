get_tcga_copynumber_results <- function(){
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
      gene = Gene,
      feature = Metric,
      direction = Direction,
      mean_normal = Mean_Normal,
      mean_cnv = Mean_CNV,
      t_stat = T_stat,
      p_value = Pvalue,
      log10_p_value = Neg_log10_pvalue
    ) %>%
    dplyr::mutate(feature = stringr::str_replace_all(feature, "\\.", "_"))

  rm(immunetable)
  rm(studytable)
  rm(subtypetable)
  return(tbl)
}
