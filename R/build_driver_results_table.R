build_driver_results_table <- function() {

  # driver_results import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for driver_results."), fill = TRUE)
  driver_results <- read_iatlas_data_file(get_feather_file_folder(), "driver_results") %>%
    dplyr::distinct(hgnc, tag, feature, p_value, fold_change, log10_p_value, log10_fold_change, n_wt, n_mut) %>%
    dplyr::filter(!is.na(hgnc)) %>%
    dplyr::arrange(hgnc, tag, feature)
  cat(crayon::blue("Imported feather files for driver_results."), fill = TRUE)

  # driver_results data ---------------------------------------------------
  cat(crayon::magenta("Building driver_results data."), fill = TRUE)
  driver_results <- driver_results %>% dplyr::left_join(
    iatlas.data::read_table("features") %>%
      dplyr::as_tibble() %>%
      dplyr::select(feature_id = id, feature = name),
    by = "feature"
  )

  # This should be joined by entrez.
  driver_results <- driver_results %>% dplyr::left_join(get_genes(), by = "hgnc")

  driver_results <- driver_results %>% dplyr::select(gene_id, tag_id, feature_id, p_value, fold_change, log10_p_value, log10_fold_change, n_wt, n_mut)
  cat(crayon::blue("Built driver_results data."), fill = TRUE)

  # driver_results table ---------------------------------------------------
  cat(crayon::magenta("Building driver_results table.\n\t(Please be patient, this may take a little while as there are", nrow(driver_results), "rows to write.)"), fill = TRUE, spe = " ")
  table_written <- driver_results %>% iatlas.data::replace_table("driver_results")
  cat(crayon::blue("Built driver_results table. (", nrow(driver_results), "rows )"), fill = TRUE, sep = " ")

}
