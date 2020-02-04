build_samples_to_tags_table <- function() {

  # samples_to_tags import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for samples_to_tags."), fill = TRUE)
  samples_to_tags <- read_iatlas_data_file(
    get_feather_file_folder(),
    "relationships/samples_to_tags"
  ) %>%
    dplyr::distinct(sample_id, tag_id) %>%
    dplyr::filter(!is.na(sample_id) & !is.na(tag_id)) %>%
    dplyr::arrange(sample_id, tag_id)
  cat(crayon::blue("Imported feather files for samples_to_tags."), fill = TRUE)

  # samples_to_tags data ---------------------------------------------------
  cat(crayon::magenta("Building samples_to_tags data."), fill = TRUE)
  samples_to_tags <- samples_to_tags %>% dplyr::left_join(
    iatlas.data::read_table("tags") %>%
      dplyr::as_tibble() %>%
      dplyr::select(tag_id = id, tag = name),
    by = "tag"
  )

  samples_to_tags <- samples_to_tags %>% dplyr::left_join(
    get_samples() %>%
      dplyr::as_tibble() %>%
      dplyr::select(sample_id = id, sample = name),
    by = "sample"
  )
  cat(crayon::blue("Built samples_to_tags data."), fill = TRUE)

  # samples_to_tags table ---------------------------------------------------
  cat(crayon::magenta("Building samples_to_tags table."), fill = TRUE)
  samples_to_tags %>% iatlas.data::replace_table("samples_to_tags")
  cat(crayon::blue("Built samples_to_tags table. (", nrow(samples_to_tags), "rows )"), fill = TRUE, sep = " ")

}
