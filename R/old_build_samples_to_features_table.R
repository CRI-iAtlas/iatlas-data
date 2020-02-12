old_build_samples_to_features_table <- function(feather_file_folder, old_get_all_samples, samples) {

  cat(crayon::magenta("Building samples_to_features data."), fill = TRUE)
  sample_set_features <- old_get_all_samples() %>%
    dplyr::distinct(sample, feature, value) %>%
    dplyr::inner_join(old_read_features(), by = c("feature" = "name")) %>%
    dplyr::rename(feature_id = id) %>%
    dplyr::distinct(sample, feature_id, value)

  features_to_samples <- sample_set_features %>%
    dplyr::inner_join(samples, by = c("sample" = "name")) %>%
    dplyr::distinct(id, feature_id, value) %>%
    dplyr::rename(sample_id = id) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(inf_value = ifelse(is.infinite(value), value, NA), value = ifelse(is.finite(value), value, NA))
  cat(crayon::blue("Built samples_to_features data."), fill = TRUE)

  cat(crayon::magenta("Building features_to_samples table.\n\t(Please be patient, this may take a little while as there are", nrow(features_to_samples), "rows to write.)"), fill = TRUE, sep = " ")
  features_to_samples %>% iatlas.data::replace_table("features_to_samples")
  cat(crayon::blue("Built features_to_samples table. (", nrow(features_to_samples), "rows )"), fill = TRUE, sep = " ")
}
