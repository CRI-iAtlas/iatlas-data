build_features_to_samples_table <- function() {

  cat(crayon::magenta("Building features_to_samples data."), fill = TRUE)
  features_to_samples <- read_iatlas_data_file(
    get_feather_file_folder(),
    "relationships/features_to_samples"
  ) %>%
    dplyr::distinct(feature_id, sample_id) %>%
    dplyr::filter(!is.na(feature_id) & !is.na(sample_id)) %>%
    dplyr::arrange(feature_id, sample_id)

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
  cat(crayon::blue("Built features_to_samples data."), fill = TRUE)

  cat(crayon::magenta("Building features_to_samples table.\n\t(Please be patient, this may take a little while as there are", nrow(features_to_samples), "rows to write.)"), fill = TRUE, sep = " ")
  features_to_samples %>% iatlas.data::replace_table("features_to_samples")
  cat(crayon::blue("Built features_to_samples table. (", nrow(features_to_samples), "rows )"), fill = TRUE, sep = " ")
}
