build_datasets_tables <- function(...) {

  # datasets import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for datasets."), fill = TRUE)
  datasets <- synapse_read_all_feather_files("syn22165541")
  cat(crayon::blue("Imported feather files for datasets."), fill = TRUE)

  # datasets column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring datasets have all the correct columns and no dupes."), fill = TRUE)
  datasets <- datasets %>%
    dplyr::bind_rows(dplyr::tibble(
      name = character(),
      display = character()
    )) %>%
    dplyr::filter(!is.na(name), !is.na(display)) %>%
    dplyr::distinct() %>%
    iatlas.data::resolve_df_dupes(., keys = c("name")) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Ensured datasets have all the correct columns and no dupes."), fill = TRUE)

  # datasets table ---------------------------------------------------
  cat(crayon::magenta("Building datasets table."), fill = TRUE)
  table_written <- iatlas.data::replace_table(datasets, "datasets")
  cat(crayon::blue("Built datasets table. (", nrow(datasets), "rows )"), fill = TRUE, sep = " ")

}
