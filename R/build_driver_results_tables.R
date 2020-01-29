build_driver_results_tables <- function(feather_file_folder) {

  all_driver_results <- read_iatlas_data_file(feather_file_folder, "SQLite_data/driver_results*.feather")

  cat(crayon::magenta("Building driver_results data."), fill = TRUE)
  features <- iatlas.data::read_table("features") %>%
    dplyr::as_tibble() %>%
    dplyr::select(id, name) %>%
    dplyr::rename_at("id", ~("feature_id"))
  genes <- iatlas.data::read_table("genes") %>%
    dplyr::as_tibble() %>%
    dplyr::select(id, hgnc) %>%
    dplyr::rename_at("id", ~("gene_id"))
  tags <- iatlas.data::read_table("tags") %>%
    dplyr::as_tibble() %>%
    dplyr::select(id, name) %>%
    dplyr::rename_at("id", ~("tag_id"))
  results <- all_driver_results %>%
    dplyr::mutate(hgnc = ifelse(!is.na(label), iatlas.data::driver_results_label_to_hgnc(label), NA)) %>%
    dplyr::rename_at("pvalue", ~("p_value")) %>%
    dplyr::rename_at("log10_pvalue", ~("log10_p_value")) %>%
    dplyr::mutate(hgnc = iatlas.data::driver_results_label_to_hgnc(label)) %>%
    dplyr::inner_join(features, by = c("feature" = "name")) %>%
    dplyr::inner_join(genes, by = "hgnc") %>%
    dplyr::inner_join(tags, by = c("group" = "name")) %>%
    dplyr::select(-c("feature", "group", "hgnc", "label", "parent_group"))
  cat(crayon::blue("Built driver_results data."), fill = TRUE)

  cat(crayon::magenta("Building driver_results table.\n(Please be patient, this may take a little while as there are", nrow(results), "rows to write.)"), fill = TRUE, spe = " ")
  table_written <- results %>% iatlas.data::replace_table("driver_results")
  cat(crayon::blue("Built driver_results table. (", nrow(results), "rows )"), fill = TRUE, sep = " ")
}