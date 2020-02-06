build_features_to_samples_table <- function() {

  # features_to_samples import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for features_to_samples."), fill = TRUE)
  features_to_samples <- read_iatlas_data_file(
    get_feather_file_folder(),
    "relationships/features_to_samples"
  ) %>%
    dplyr::distinct(feature, sample, .keep_all = TRUE) %>%
    dplyr::filter(!is.na(feature) & !is.na(sample)) %>%
    dplyr::arrange(feature, sample)
  cat(crayon::blue("Imported feather files for features_to_samples."), fill = TRUE)

  # features_to_samples data ---------------------------------------------------
  cat(crayon::magenta("Building features_to_samples data."), fill = TRUE)
  features_to_samples <- features_to_samples %>% dplyr::left_join(
    iatlas.data::read_table("features") %>%
      dplyr::as_tibble() %>%
      dplyr::select(feature_id = id, feature = name),
    by = "feature"
  )

  features_to_samples <- features_to_samples %>% dplyr::left_join(
    get_samples() %>%
      dplyr::as_tibble() %>%
      dplyr::select(sample_id = id, sample = name),
    by = "sample"
  )

  features_to_samples <- features_to_samples %>%
    dplyr::select(feature_id, sample_id, value) %>%
    dplyr::mutate(inf_value = ifelse(is.infinite(value), value, NA), value = ifelse(is.finite(value), value, NA))
  cat(crayon::blue("Built features_to_samples data."), fill = TRUE)

  # features_to_samples table ---------------------------------------------------
  cat(crayon::magenta("Building features_to_samples table.\n\t(Please be patient, this may take a little while as there are", nrow(features_to_samples), "rows to write.)"), fill = TRUE, sep = " ")
  table_written <- features_to_samples %>% iatlas.data::replace_table("features_to_samples")
  cat(crayon::blue("Built features_to_samples table. (", nrow(features_to_samples), "rows )"), fill = TRUE, sep = " ")
}
