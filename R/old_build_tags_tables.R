old_build_tags_tables <- function(feather_file_folder) {
  cat(crayon::magenta("Importing feather file for tags."), fill = TRUE)
  initial_tags <- iatlas.data::read_iatlas_data_file(feather_file_folder, "/SQLite_data/groups.feather") %>%
    dplyr::rename(name = group, display = group_name)
  cat(crayon::blue("Imported feather file for tags."), fill = TRUE)

  cat(crayon::magenta("Building tags data"), fill = TRUE)
  parents <- initial_tags %>%
    dplyr::filter(!is.na(parent_group)) %>%
    dplyr::distinct(parent_group, .keep_all = TRUE) %>%
    dplyr::select(parent_group, parent_group_display) %>%
    dplyr::rename(name = parent_group,display = parent_group_display) %>%
    tibble::add_column(characteristics = NA, color = NA, .after = "display") %>%
    dplyr::arrange(name)
  subtype <- initial_tags %>%
    dplyr::filter(!is.na(subtype_group)) %>%
    dplyr::distinct(subtype_group, .keep_all = TRUE) %>%
    dplyr::select(subtype_group, subtype_group_display) %>%
    dplyr::rename(name = subtype_group, display = subtype_group_display) %>%
    tibble::add_column(characteristics = NA, color = NA, .after = "display") %>%
    dplyr::arrange(name)
  tags <- parents %>%
    dplyr::bind_rows(initial_tags, subtype) %>%
    dplyr::arrange(name) %>%
    dplyr::distinct(name, .keep_all = TRUE)
  cat(crayon::blue("Built tags data"), fill = TRUE)

  cat(crayon::magenta("Building tags table."), fill = TRUE)
  table_written <- tags %>%
    dplyr::select(-c("parent_group", "parent_group_display", "subtype_group", "subtype_group_display")) %>%
    iatlas.data::write_table_ts("tags")
  cat(crayon::blue("Built tags table. (", nrow(tags), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building tags_to_tags data."), fill = TRUE)
  tags_db <- iatlas.data::read_table("tags") %>%
    dplyr::as_tibble() %>%
    dplyr::select(id, name)
  all_tags_with_tag_ids <- tags %>%
    dplyr::inner_join(tags_db, by = "name") %>%
    dplyr::select(id, parent_group, subtype_group) %>%
    dplyr::rename(tag_id = id)
  related_parent_tags <- all_tags_with_tag_ids %>%
    dplyr::rename(name = parent_group) %>%
    dplyr::inner_join(tags_db, by = "name") %>%
    dplyr::select(tag_id, id) %>%
    dplyr::rename(related_tag_id = id)
  related_subtype_tags <- all_tags_with_tag_ids %>%
    dplyr::rename(name = subtype_group) %>%
    dplyr::inner_join(tags_db, by = "name") %>%
    dplyr::select(tag_id, id) %>%
    dplyr::rename(related_tag_id = id)
  tags_to_tags <- related_parent_tags %>%
    dplyr::bind_rows(related_subtype_tags) %>%
    dplyr::distinct(tag_id, related_tag_id)
  cat(crayon::magenta("Built tags_to_tags data."), fill = TRUE)

  cat(crayon::magenta("Building tags_to_tags table."), fill = TRUE)
  table_written <- tags_to_tags %>% iatlas.data::write_table_ts("tags_to_tags")
  cat(crayon::magenta("Built tags_to_tags table. (", nrow(tags_to_tags), "rows )"), fill = TRUE, sep = " ")
}
