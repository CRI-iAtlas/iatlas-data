build_tags_tables <- function() {

  # tags import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for tags."), fill = TRUE)
  tags <- read_iatlas_data_file(get_feather_file_folder(), "tags") %>%
    dplyr::distinct(name, characteristics, display, color) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Imported feather files for tags."), fill = TRUE)

  # tags table ---------------------------------------------------
  cat(crayon::magenta("Building tags table."), fill = TRUE)
  table_written <- tags %>% iatlas.data::replace_table("tags")
  cat(crayon::blue("Built tags table. (", nrow(tags), "rows )"), fill = TRUE, sep = " ")

  # tags_to_tags import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for tags_to_tags."), fill = TRUE)
  tags_to_tags <- read_iatlas_data_file(get_feather_file_folder(), "relationships/tags_to_tags") %>%
    dplyr::distinct(tag, related_tag) %>%
    dplyr::arrange(tag)

  tags_to_tags <- tags_to_tags %>% dplyr::left_join(
    iatlas.data::read_table("tags") %>%
      dplyr::as_tibble() %>%
      dplyr::select(tag_id = id, tag = name),
    by = "tag"
  )

  tags_to_tags <- tags_to_tags %>% dplyr::left_join(
    iatlas.data::read_table("tags") %>%
      dplyr::as_tibble() %>%
      dplyr::select(related_tag_id = id, related_tag = name),
    by = "related_tag"
  )

  tags_to_tags <- tags_to_tags %>% dplyr::select(tag_id, related_tag_id)
  cat(crayon::blue("Imported feather files for tags_to_tags."), fill = TRUE)

  # tags_to_tags table ---------------------------------------------------
  cat(crayon::magenta("Building tags_to_tags table."), fill = TRUE)
  table_written <- tags_to_tags %>% iatlas.data::replace_table("tags_to_tags")
  cat(crayon::blue("Built tags_to_tags table. (", nrow(tags_to_tags), "rows )"), fill = TRUE, sep = " ")

}
