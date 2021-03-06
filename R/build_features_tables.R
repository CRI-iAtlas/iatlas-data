build_features_tables <- function(...) {

  # features import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for features."), fill = TRUE)
  features <- synapse_read_all_feather_files("syn22125617")
  cat(crayon::blue("Imported feather files for features."), fill = TRUE)

  # features column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring features have all the correct columns and no dupes."), fill = TRUE)
  features <- features %>%
    dplyr::bind_rows(dplyr::tibble(
      class = character(),
      display = character(),
      method_tag = character(),
      name = character(),
      order = numeric(),
      unit = character()
    )) %>%
    dplyr::distinct(class, display, method_tag, name, order, unit) %>%
    dplyr::filter(!is.na(name)) %>%
    iatlas.data::resolve_df_dupes(keys = c("name")) %>%
    dplyr::select(class, display, method_tag, name, order, unit) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Ensured features have all the correct columns and no dupes."), fill = TRUE)

  # classes data ---------------------------------------------------
  cat(crayon::magenta("Building classes data."), fill = TRUE)
  classes <- features %>%
    dplyr::filter(!is.na(class)) %>%
    dplyr::distinct(name = class) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Built classes data."), fill = TRUE)

  # classes table ---------------------------------------------------
  cat(crayon::magenta("Building classes table."), fill = TRUE)
  table_written <- classes %>% iatlas.data::replace_table("classes")
  cat(crayon::blue("Built classes table. (", nrow(classes), "rows )"), fill = TRUE, sep = " ")

  # method_tags data ---------------------------------------------------
  cat(crayon::magenta("Building method_tags data."), fill = TRUE)
  method_tags <- features %>%
    dplyr::filter(!is.na(method_tag)) %>%
    dplyr::distinct(name = method_tag) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Built method_tags data"), fill = TRUE)

  # method_tags table ---------------------------------------------------
  cat(crayon::magenta("Building method_tags table."), fill = TRUE)
  table_written <- method_tags %>% iatlas.data::replace_table("method_tags")
  cat(crayon::blue("Built method_tags table. (", nrow(method_tags), "rows )"), fill = TRUE, sep = " ")

  # features data ---------------------------------------------------
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
      dplyr::select(method_tag_id = id, method_tag = name),
    by = "method_tag"
  )

  features <- features %>% dplyr::select(name, display, class_id, method_tag_id, order, unit)
  cat(crayon::blue("Built features data"), fill = TRUE)

  # features table ---------------------------------------------------
  cat(crayon::magenta("Built features table."), fill = TRUE)
  table_written <- features %>% iatlas.data::replace_table("features")
  cat(crayon::blue("Built features table. (", nrow(features), "rows )"), fill = TRUE, sep = " ")
}
