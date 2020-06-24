build_publications_table <- function(...) {

  # publications import ---------------------------------------------------
  cat(crayon::magenta("Importing files for publications"), fill = TRUE)
  publications <- synapse_read_all_feather_files("syn22168316")
  cat(crayon::blue("Imported files for publications"), fill = TRUE)

  # publications column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring publications have all the correct columns and no dupes."), fill = TRUE)
  publications <- publications %>%
    dplyr::bind_rows(dplyr::tibble(
      pubmed_id = integer(),
      journal = character(),
      first_author_last_name = character(),
      year = integer(),
      title = character()
    )) %>%
    dplyr::filter(!is.na(pubmed_id)) %>%
    dplyr::distinct() %>%
    iatlas.data::resolve_df_dupes(keys = c("pubmed_id")) %>%
    dplyr::arrange(pubmed_id)
  cat(crayon::blue("Ensured publications have all the correct columns and no dupes."), fill = TRUE)

  # publication table ---------------------------------------------------
  cat(crayon::magenta("Building the publications table."), fill = TRUE)
  table_written <- iatlas.data::replace_table(publications, "publications")
  cat(crayon::blue("Built the publications table. (", nrow(publications), "rows )"), fill = TRUE, sep = " ")

}
