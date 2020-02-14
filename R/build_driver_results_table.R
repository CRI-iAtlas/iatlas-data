build_driver_results_table <- function() {

  # driver_results import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for driver_results."), fill = TRUE)
  driver_results <- iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "driver_results")
  cat(crayon::blue("Imported feather files for driver_results."), fill = TRUE)

  # driver_results column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring driver results have all the correct columns and no dupes."), fill = TRUE)
  driver_results <- driver_results %>%
    dplyr::bind_rows(dplyr::tibble(
      entrez = numeric(),
      hgnc = character(),
      tag = character(),
      feature = character(),
      mutation_code = character(),
      p_value = numeric(),
      fold_change = numeric(),
      log10_p_value = numeric(),
      log10_fold_change = numeric(),
      n_wt = integer(),
      n_mut = integer()
    )) %>%
    dplyr::distinct(entrez, hgnc, tag, feature, mutation_code, p_value, fold_change, log10_p_value, log10_fold_change, n_wt, n_mut) %>%
    iatlas.data::resolve_df_dupes(keys = c("entrez", "tag", "feature", "mutation_code")) %>%
    dplyr::select(entrez, hgnc, tag, feature, mutation_code, p_value, fold_change, log10_p_value, log10_fold_change, n_wt, n_mut) %>%
    dplyr::arrange(entrez, tag, feature, mutation_code)
  cat(crayon::blue("Ensured driver results have all the correct columns and no dupes."), fill = TRUE)

  # driver_results data ---------------------------------------------------
  cat(crayon::magenta("Building driver_results data."), fill = TRUE)
  driver_results <- driver_results %>% dplyr::left_join(iatlas.data::get_features(), by = "feature")

  driver_results <- driver_results %>% dplyr::left_join(iatlas.data::get_tags(), by = "tag")

  driver_results <- driver_results %>% dplyr::left_join(iatlas.data::get_mutation_codes(), by = c("mutation_code" = "code"))

  # This should be joined by entrez.
  driver_results <- driver_results %>% dplyr::left_join(get_genes(), by = "hgnc")

  driver_results <- driver_results %>% dplyr::select(gene_id, tag_id, feature_id, mutation_code_id, p_value, fold_change, log10_p_value, log10_fold_change, n_wt, n_mut)
  cat(crayon::blue("Built driver_results data."), fill = TRUE)

  # driver_results table ---------------------------------------------------
  cat(crayon::magenta("Building driver_results table.\n\t(Please be patient, this may take a little while as there are", nrow(driver_results), "rows to write.)"), fill = TRUE, spe = " ")
  table_written <- driver_results %>% iatlas.data::replace_table("driver_results")
  cat(crayon::blue("Built driver_results table. (", nrow(driver_results), "rows )"), fill = TRUE, sep = " ")

}
