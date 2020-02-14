old_build_features_to_samples_table <- function() {

  cat(crayon::magenta("Building features_to_samples data."), fill = TRUE)
  features_to_samples <- old_get_all_samples() %>%
    dplyr::filter(!is.na(feature)) %>%
    dplyr::distinct(sample, feature, value) %>%
    dplyr::left_join(old_read_features(), by = "feature") %>%
    dplyr::distinct(sample, feature_id, value)

  features_to_samples <- features_to_samples %>%
    dplyr::left_join(old_read_samples(), by = "sample") %>%
    dplyr::distinct(sample_id, feature_id, value) %>%
    dplyr::mutate(inf_value = ifelse(is.infinite(value), value, NA), value = ifelse(is.finite(value), value, NA))
  cat(crayon::blue("Built features_to_samples data."), fill = TRUE)

  # features_to_samples table ---------------------------------------------------
  cat(crayon::magenta("Building features_to_samples table.\n\t(Please be patient, this may take a little while as there are", nrow(features_to_samples), "rows to write.)"), fill = TRUE, sep = " ")
  table_written <- features_to_samples %>% iatlas.data::replace_table("features_to_samples")
  cat(crayon::blue("Built features_to_samples table. (", nrow(features_to_samples), "rows )"), fill = TRUE, sep = " ")
}
