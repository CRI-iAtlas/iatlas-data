old_build_driver_results_tables <- function() {

  all_driver_results <- iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "SQLite_data/driver_results*.feather")

  cat(crayon::magenta("Building driver_results data."), fill = TRUE)

  results <- all_driver_results %>%
    dplyr::mutate(gene_mutation = iatlas.data::driver_results_label_to_hgnc(label)) %>%
    tidyr::separate(gene_mutation, into = c("hgnc", "code"), sep = "\\s", remove = TRUE) %>%
    dplyr::left_join(old_read_features(), by = "feature") %>%
    dplyr::left_join(old_read_genes(), by = "hgnc") %>%
    dplyr::left_join(old_read_tags(), by = c("group" = "tag")) %>%
    dplyr::left_join(old_read_mutation_codes(), by = "code") %>%
    dplyr::select(
      gene_id,
      mutation_code_id,
      feature_id,
      tag_id,
      p_value = pvalue,
      log10_p_value = log10_pvalue,
      fold_change,
      log10_fold_change,
      n_wt,
      n_mut
    )
  cat(crayon::blue("Built driver_results data."), fill = TRUE)

  cat(crayon::magenta("Building driver_results table.\n\t(Please be patient, this may take a little while as there are", nrow(results), "rows to write.)"), fill = TRUE, spe = " ")
  table_written <- results %>% iatlas.data::replace_table("driver_results")
  cat(crayon::blue("Built driver_results table. (", nrow(results), "rows )"), fill = TRUE, sep = " ")
}
