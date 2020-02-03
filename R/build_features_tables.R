build_features_tables <- function(feather_file_folder) {
  default_class <- "Other"

  cat(crayon::magenta("Importing feather files for features."), fill = TRUE)
  features <- read_iatlas_data_file(feather_file_folder, "features") %>%
    dplyr::distinct(class, display, method_tag, name, order, unit) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Imported feather files for features."), fill = TRUE)

  cat(crayon::magenta("Building classes data."), fill = TRUE)
  classes <- features %>%
    dplyr::filter(!is.na(class)) %>%
    dplyr::distinct(name = class) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Built classes data."), fill = TRUE)

  # Create the classes table with data.
  cat(crayon::magenta("Building classes table."), fill = TRUE)
  table_written <- classes %>% iatlas.data::write_table_ts("classes")
  cat(crayon::blue("Built classes table. (", nrow(classes), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building method_tags data."), fill = TRUE)
  method_tags <- features %>%
    dplyr::filter(!is.na(methods_tag)) %>%
    dplyr::distinct(name = methods_tag) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Built method_tags data"), fill = TRUE)

  # Create the method_tags table with data.
  cat(crayon::magenta("Building method_tags table."), fill = TRUE)
  table_written <- method_tags %>% iatlas.data::write_table_ts("method_tags")
  cat(crayon::blue("Built method_tags table. (", nrow(method_tags), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building features data."), fill = TRUE)
  features <- features %>% dplyr::left_join(
    iatlas.data::read_table("classes") %>%
      dplyr::as_tibble() %>%
      dplyr::select(class_id = id, class = name),
    by = "class"
  )

  features <- features %>% dplyr::left_join(
    iatlas.data::read_table("method_tags") %>%
      dplyr::as_tibble() %>%
      dplyr::select(method_tag_id = id, methods_tag = name),
    by = "methods_tag"
  )

  features <- features %>% dplyr::select(name, display, class_id, method_tag_id, order, unit)
  cat(crayon::blue("Built features data"), fill = TRUE)

  cat(crayon::magenta("Built features table."), fill = TRUE)
  table_written <- features %>% iatlas.data::write_table_ts("features")
  cat(crayon::blue("Built features table. (", nrow(features), "rows )"), fill = TRUE, sep = " ")
}
