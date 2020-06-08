build_samples_to_tags_table <- function() {

  # samples_to_tags import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for samples_to_tags."), fill = TRUE)
  samples_to_tags <- synapse_read_all_feather_files("syn22125729") %>%
    dplyr::filter(!is.na(sample) & !is.na(tag)) %>%
    dplyr::distinct(sample, tag) %>%
    dplyr::arrange(sample, tag)
  cat(crayon::blue("Imported feather files for samples_to_tags."), fill = TRUE)

  # samples_to_tags data ---------------------------------------------------
  cat(crayon::magenta("Building samples_to_tags data."), fill = TRUE)
  samples_to_tags <- samples_to_tags %>% dplyr::left_join(
    iatlas.data::get_tags(),
    by = "tag"
  )

  samples_to_tags <- samples_to_tags %>% dplyr::left_join(
    iatlas.data::get_samples() %>%
      dplyr::as_tibble() %>%
      dplyr::select(sample_id = id, sample = name),
    by = "sample"
  )

  samples_to_tags <- samples_to_tags %>% dplyr::select(sample_id, tag_id)
  cat(crayon::blue("Built samples_to_tags data."), fill = TRUE)

  # samples_to_tags table ---------------------------------------------------
  cat(crayon::magenta("Building samples_to_tags table."), fill = TRUE)
  table_written <- samples_to_tags %>% iatlas.data::replace_table("samples_to_tags")
  cat(crayon::blue("Built samples_to_tags table. (", nrow(samples_to_tags), "rows )"), fill = TRUE, sep = " ")

}
