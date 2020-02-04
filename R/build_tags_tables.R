build_tags_tables <- function() {

  cat(crayon::magenta("Importing feather files for tags."), fill = TRUE)
  tags <- read_iatlas_data_file(get_feather_file_folder(), "tags") %>%
    dplyr::distinct(name, characteristics, display, color) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Imported feather files for tags."), fill = TRUE)

  cat(crayon::magenta("Building tags table."), fill = TRUE)
  table_written <- tags %>%
    dplyr::select(-c("parent_group", "parent_group_display", "subtype_group", "subtype_group_display")) %>%
    iatlas.data::write_table_ts("tags")
  cat(crayon::blue("Built tags table. (", nrow(tags), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Importing feather files for tags_to_tags."), fill = TRUE)
  tags_to_tags <- read_iatlas_data_file(get_feather_file_folder(), "tags_to_tags") %>%
    dplyr::distinct(tag_id, related_tag_id) %>%
    dplyr::arrange(tag_id)
  cat(crayon::blue("Imported feather files for tags_to_tags."), fill = TRUE)

  cat(crayon::magenta("Building tags_to_tags table."), fill = TRUE)
  table_written <- tags_to_tags %>% iatlas.data::write_table_ts("tags_to_tags")
  cat(crayon::blue("Built tags_to_tags table. (", nrow(tags_to_tags), "rows )"), fill = TRUE, sep = " ")
}
