build_features_to_samples_table <- function(all_samples_with_patient_ids, samples) {
  cat(crayon::magenta("Building features_to_samples data."), fill = TRUE)
  features <- iatlas.data::read_table("features") %>%
    dplyr::as_tibble() %>%
    dplyr::select(id, name)
  sample_set_features <- all_samples_with_patient_ids %>%
    dplyr::distinct(sample, feature, value) %>%
    dplyr::inner_join(features, by = c("feature" = "name")) %>%
    dplyr::distinct(sample, feature_id = id, value)
  features_to_samples <- sample_set_features %>%
    dplyr::inner_join(samples, by = c("sample" = "name")) %>%
    dplyr::distinct(sample_id = id, feature_id, value) %>%
    dplyr::mutate(inf_value = ifelse(is.infinite(value), value, NA), value = ifelse(is.finite(value), value, NA))
  cat(crayon::blue("Built features_to_samples data."), fill = TRUE)

  # features_to_samples table ---------------------------------------------------
  cat(crayon::magenta("Building features_to_samples table.\n\t(Please be patient, this may take a little while as there are", nrow(features_to_samples), "rows to write.)"), fill = TRUE, sep = " ")
  features_to_samples %>% iatlas.data::replace_table("features_to_samples")
  cat(crayon::blue("Built features_to_samples table. (", nrow(features_to_samples), "rows )"), fill = TRUE, sep = " ")

}