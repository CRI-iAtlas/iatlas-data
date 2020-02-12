old_build_driver_results_tables <- function() {

  all_driver_results <- iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "SQLite_data/driver_results*.feather")

  cat(crayon::magenta("Building driver_results data."), fill = TRUE)
  features  <- old_read_features()  %>% dplyr::rename(feature_id  = id)
  genes     <- old_read_genes()     %>% dplyr::rename(gene_id     = id)
  tags      <- old_read_tags()      %>% dplyr::rename(tag_id      = id)

  results <- all_driver_results %>%
    dplyr::mutate(hgnc = ifelse(!is.na(label), iatlas.data::driver_results_label_to_hgnc(label), NA)) %>%
    dplyr::rename(p_value = pvalue) %>%
    dplyr::rename(log10_p_value = log10_pvalue) %>%
    dplyr::mutate(hgnc = iatlas.data::driver_results_label_to_hgnc(label)) %>%
    dplyr::inner_join(features, by = c("feature" = "name")) %>%
    dplyr::inner_join(genes, by = "hgnc") %>%
    dplyr::inner_join(tags, by = c("group" = "name")) %>%
    dplyr::select(-c("feature", "group", "hgnc", "label", "parent_group"))
  cat(crayon::blue("Built driver_results data."), fill = TRUE)

  cat(crayon::magenta("Building driver_results table.\n\t(Please be patient, this may take a little while as there are", nrow(results), "rows to write.)"), fill = TRUE, spe = " ")
  table_written <- results %>% iatlas.data::replace_table("driver_results")
  cat(crayon::blue("Built driver_results table. (", nrow(results), "rows )"), fill = TRUE, sep = " ")
}
