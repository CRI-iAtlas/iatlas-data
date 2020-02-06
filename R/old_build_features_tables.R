old_build_features_tables <- function(feather_file_folder) {
  default_class <- "Other"

  cat(crayon::magenta("Importing feather file for features."), fill = TRUE)
  features <- iatlas.data::read_iatlas_data_file(feather_file_folder, "/SQLite_data/features.feather") %>%
    dplyr::rename(name = feature) %>%
    dplyr::mutate(class = ifelse(is.na(class), default_class, class))
  cat(crayon::blue("Imported feather file for features."), fill = TRUE)

  cat(crayon::magenta("Building classes data."), fill = TRUE)
  classes <- features %>%
    dplyr::distinct(class) %>%
    dplyr::rename(name = class) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Built classes data."), fill = TRUE)

  # Create the classes table with data.
  cat(crayon::magenta("Building classes table."), fill = TRUE)
  table_written <- classes %>% iatlas.data::write_table_ts("classes")
  cat(crayon::blue("Built classes table. (", nrow(classes), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building method_tags data."), fill = TRUE)
  method_tags <- features %>%
    dplyr::filter(!is.na(methods_tag)) %>%
    dplyr::distinct(methods_tag) %>%
    dplyr::rename(name = methods_tag) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Built method_tags data"), fill = TRUE)

  # Create the method_tags table with data.
  cat(crayon::magenta("Building method_tags table."), fill = TRUE)
  table_written <- method_tags %>% iatlas.data::write_table_ts("method_tags")
  cat(crayon::blue("Built method_tags table. (", nrow(method_tags), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building features data."), fill = TRUE)
  classes <- iatlas.data::read_table("classes") %>% dplyr::as_tibble()
  method_tags <- iatlas.data::read_table("method_tags") %>% dplyr::as_tibble()
  features <- features %>%
    dplyr::left_join(classes, by = c("class" = "name")) %>%
    dplyr::rename(class_id = id) %>%
    dplyr::left_join(method_tags, by = c("methods_tag" = "name")) %>%
    dplyr::rename(method_tag_id = id) %>%
    dplyr::select(name, display, order, unit, class_id, method_tag_id) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Built features data"), fill = TRUE)

  cat(crayon::magenta("Built features table."), fill = TRUE)
  table_written <- features %>% iatlas.data::write_table_ts("features")
  cat(crayon::blue("Built features table. (", nrow(features), "rows )"), fill = TRUE, sep = " ")
}
