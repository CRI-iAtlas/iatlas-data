old_build_tags_tables <- function() {
  cat(crayon::magenta("Importing feather file for tags."), fill = TRUE)
  initial_tags <- read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "SQLite_data/groups.feather") %>%
    dplyr::rename(name = group, display = group_name)
  cat(crayon::blue("Imported feather file for tags."), fill = TRUE)

  cat(crayon::magenta("Building tags data"), fill = TRUE)
  parents <- initial_tags %>%
    dplyr::filter(!is.na(parent_group)) %>%
    dplyr::distinct(parent_group, .keep_all = TRUE) %>%
    dplyr::select(name = parent_group, display = parent_group_display)
  subtype <- initial_tags %>%
    dplyr::filter(!is.na(subtype_group)) %>%
    dplyr::distinct(subtype_group, .keep_all = TRUE) %>%
    dplyr::select(name = subtype_group, display = subtype_group_display)
  tags <- parents %>%
    dplyr::bind_rows(initial_tags, subtype) %>%
    dplyr::distinct(name, .keep_all = TRUE) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Built tags data"), fill = TRUE)

  cat(crayon::magenta("Building tags table."), fill = TRUE)
  table_written <- tags %>%
    dplyr::select(name, characteristics, display, color) %>%
    iatlas.data::replace_table("tags")
  cat(crayon::blue("Built tags table. (", nrow(tags), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building tags_to_tags data."), fill = TRUE)
  tags_db <- old_read_tags()
  all_tags_with_tag_ids <- tags %>%
    dplyr::left_join(tags_db, by = c("name" = "tag")) %>%
    dplyr::select(tag_id, parent_group, subtype_group)
  related_parent_tags <- all_tags_with_tag_ids %>%
    dplyr::rename(name = parent_group) %>%
    dplyr::left_join(tags_db %>% dplyr::rename(related_tag_id = tag_id), by = c("name" = "tag")) %>%
    dplyr::select(tag_id, related_tag_id)
  related_subtype_tags <- all_tags_with_tag_ids %>%
    dplyr::rename(name = subtype_group) %>%
    dplyr::left_join(tags_db %>% dplyr::rename(related_tag_id = tag_id), by = c("name" = "tag")) %>%
    dplyr::select(tag_id, related_tag_id)
  tags_to_tags <- related_parent_tags %>%
    dplyr::bind_rows(related_subtype_tags) %>%
    dplyr::filter(!is.na(related_tag_id)) %>%
    dplyr::distinct(tag_id, related_tag_id)
  cat(crayon::magenta("Built tags_to_tags data."), fill = TRUE)

  cat(crayon::magenta("Building tags_to_tags table."), fill = TRUE)
  table_written <- tags_to_tags %>% iatlas.data::replace_table("tags_to_tags")
  cat(crayon::magenta("Built tags_to_tags table. (", nrow(tags_to_tags), "rows )"), fill = TRUE, sep = " ")
}
