build_features_to_samples_table <- function(max_rows = NULL) {

  # features_to_samples import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for features_to_samples."), fill = TRUE)
  features_to_samples <- synapse_read_all_feather_files("syn22125635")
  cat(crayon::blue("Imported feather files for features_to_samples."), fill = TRUE)

  # features_to_samples column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring features_to_samples have all the correct columns and no dupes."), fill = TRUE)
  features_to_samples <- features_to_samples %>%
    dplyr::bind_rows(dplyr::tibble(
      feature = character(),
      sample = character(),
      value = numeric()
    )) %>%
    dplyr::distinct(feature, sample, value) %>%
    dplyr::filter(!is.na(feature) & !is.na(sample)) %>%
    iatlas.data::resolve_df_dupes(keys = c("feature", "sample")) %>%
    dplyr::select(feature, sample, value) %>%
    dplyr::arrange(feature, sample)
  cat(crayon::blue("Ensured features_to_samples have all the correct columns and no dupes."), fill = TRUE)

  # features_to_samples data ---------------------------------------------------
  cat(crayon::magenta("Building features_to_samples data."), fill = TRUE)
  features_to_samples <- features_to_samples %>% dplyr::left_join(iatlas.data::get_features(), by = "feature")

  features_to_samples <- features_to_samples %>% dplyr::left_join(
    iatlas.data::get_samples() %>%
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
  table_written <- features_to_samples %>% iatlas.data::replace_table("features_to_samples", max_rows = max_rows)
  cat(crayon::blue("Built features_to_samples table. (", nrow(features_to_samples), "rows )"), fill = TRUE, sep = " ")
}
