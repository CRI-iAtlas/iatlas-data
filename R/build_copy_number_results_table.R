build_copy_number_results_table <- function() {

  # copy_number_results import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for copy_number_results."), fill = TRUE)
  copy_number_results <- synapse_read_all_feather_files("syn22125983")
  cat(crayon::blue("Imported feather files for copy_number_results."), fill = TRUE)

  # copy_number_results column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring copy_number results have all the correct columns and no dupes."), fill = TRUE)
  copy_number_results <- copy_number_results %>%
    dplyr::bind_rows(dplyr::tibble(
      entrez = numeric(),
      tag = character(),
      feature = character(),
      direction = character(),
      dataset = character(),
      mean_normal = numeric(),
      mean_cnv = numeric(),
      p_value = numeric(),
      log10_p_value = numeric(),
      t_stat = numeric()
    )) %>%
    dplyr::filter(
      !is.na(entrez),
      !is.na(tag),
      !is.na(feature),
      !is.na(direction),
      !is.na(dataset)
    ) %>%
    dplyr::distinct() %>%
    dplyr::arrange(entrez, tag, feature, direction, dataset)
  cat(crayon::blue("Ensured copy_number results have all the correct columns and no dupes."), fill = TRUE)

  # copy_number_results data ---------------------------------------------------
  cat(crayon::magenta("Building copy_number_results data."), fill = TRUE)
  copy_number_results <- copy_number_results %>% dplyr::left_join(iatlas.data::get_features(), by = "feature")

  copy_number_results <- copy_number_results %>% dplyr::left_join(iatlas.data::get_tags(), by = "tag")

  copy_number_results <- copy_number_results %>% dplyr::inner_join(iatlas.data::get_genes(), by = "entrez")

  copy_number_results <- copy_number_results %>% dplyr::inner_join(iatlas.data::get_datasets(), by = "dataset")

  copy_number_results <- copy_number_results %>% dplyr::distinct()
  cat(crayon::blue("Built copy_number_results data."), fill = TRUE)

  # copy_number_results table ---------------------------------------------------
  cat(crayon::magenta("Building copy_number_results table.\n\t(Please be patient, this may take a little while as there are", nrow(copy_number_results), "rows to write.)"), fill = TRUE, spe = " ")
  table_written <- copy_number_results %>% iatlas.data::replace_table("copy_number_results")
  cat(crayon::blue("Built copy_number_results table. (", nrow(copy_number_results), "rows )"), fill = TRUE, sep = " ")

}
