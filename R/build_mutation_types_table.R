build_mutation_types_table <- function() {

  # mutation_types import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for mutation_types."), fill = TRUE)
  mutation_types <- synapse_read_all_feather_files("syn22131052")
  cat(crayon::blue("Imported feather files for mutation_types."), fill = TRUE)

  # mutation_types column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring mutation_types have all the correct columns and no dupes."), fill = TRUE)
  mutation_types <- mutation_types %>%
    dplyr::bind_rows(dplyr::tibble(
      name = character(),
      display = character()
    )) %>%
    dplyr::distinct(name, display) %>%
    dplyr::filter(!is.na(name)) %>%
    iatlas.data::resolve_df_dupes(keys = c("name")) %>%
    dplyr::select(name, display) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Ensured mutation_types have all the correct columns and no dupes."), fill = TRUE)

  # mutation_types table ---------------------------------------------------
  cat(crayon::magenta("Building mutation_types table."), fill = TRUE)
  table_written <- mutation_types %>% iatlas.data::replace_table("mutation_types")
  cat(crayon::blue("Built mutation_types table. (", nrow(mutation_types), "rows )"), fill = TRUE, sep = " ")

}
