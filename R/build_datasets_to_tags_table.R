build_datasets_to_tags_table <- function() {

  # datasets_to_tags import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for datasets_to_tags."), fill = TRUE)
  datasets_to_tags <- synapse_read_all_feather_files("syn22166402") %>%
    dplyr::filter(!is.na(dataset) & !is.na(tag)) %>%
    dplyr::distinct(dataset, tag) %>%
    dplyr::arrange(dataset, tag)
  cat(crayon::blue("Imported feather files for datasets_to_tags."), fill = TRUE)

  # datasets_to_tags data ---------------------------------------------------
  cat(crayon::magenta("Building datasets_to_tags data."), fill = TRUE)
  datasets_to_tags <- datasets_to_tags %>% dplyr::left_join(
    iatlas.data::get_tags(),
    by = "tag"
  )

  datasets_to_tags <- datasets_to_tags %>%
    dplyr::left_join(
      iatlas.data::get_datasets() %>%
        dplyr::as_tibble(),
      by = "dataset"
  )

  datasets_to_tags <- datasets_to_tags %>% dplyr::select(dataset_id, tag_id)
  cat(crayon::blue("Built datasets_to_tags data."), fill = TRUE)

  # datasets_to_tags table ---------------------------------------------------
  cat(crayon::magenta("Building datasets_to_tags table."), fill = TRUE)
  table_written <- datasets_to_tags %>% iatlas.data::replace_table("datasets_to_tags")
  cat(crayon::blue("Built datasets_to_tags table. (", nrow(datasets_to_tags), "rows )"), fill = TRUE, sep = " ")

}
