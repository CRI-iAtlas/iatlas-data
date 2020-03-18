build_copy_number_results_table <- function() {

  # copy_number_results import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for copy_number_results."), fill = TRUE)
  copy_number_results <- iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "copy_number_results")
  cat(crayon::blue("Imported feather files for copy_number_results."), fill = TRUE)

  # copy_number_results column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring copy_number results have all the correct columns and no dupes."), fill = TRUE)
  copy_number_results <- copy_number_results %>%
    dplyr::bind_rows(dplyr::tibble(
      entrez = numeric(),
      tag = character(),
      feature = character(),
      direction = character(),
      mean_normal = numeric(),
      mean_cnv = numeric(),
      p_value = numeric(),
      log10_p_value = numeric(),
      t_stat = numeric()
    )) %>%
    dplyr::distinct(entrez, tag, feature, direction, mean_normal, mean_cnv, p_value, log10_p_value, t_stat) %>%
    iatlas.data::resolve_df_dupes(keys = c("entrez", "tag", "feature")) %>%
    dplyr::select(entrez, tag, feature, direction, mean_normal, mean_cnv, p_value, log10_p_value, t_stat) %>%
    dplyr::arrange(entrez, tag, feature)
  cat(crayon::blue("Ensured copy_number results have all the correct columns and no dupes."), fill = TRUE)

  # copy_number_results data ---------------------------------------------------
  cat(crayon::magenta("Building copy_number_results data."), fill = TRUE)
  copy_number_results <- copy_number_results %>% dplyr::left_join(iatlas.data::get_features(), by = "feature")

  copy_number_results <- copy_number_results %>% dplyr::left_join(iatlas.data::get_tags(), by = "tag")

  copy_number_results <- copy_number_results %>% dplyr::left_join(iatlas.data::get_genes(), by = "entrez")

  copy_number_results <- copy_number_results %>% dplyr::distinct(gene_id, tag_id, feature_id, direction, mean_normal, mean_cnv, p_value, log10_p_value, t_stat)
  cat(crayon::blue("Built copy_number_results data."), fill = TRUE)

  # copy_number_results table ---------------------------------------------------
  cat(crayon::magenta("Building copy_number_results table.\n\t(Please be patient, this may take a little while as there are", nrow(copy_number_results), "rows to write.)"), fill = TRUE, spe = " ")
  table_written <- copy_number_results %>% iatlas.data::replace_table("copy_number_results")
  cat(crayon::blue("Built copy_number_results table. (", nrow(copy_number_results), "rows )"), fill = TRUE, sep = " ")

}
