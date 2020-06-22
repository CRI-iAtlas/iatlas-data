build_mutation_codes_table <- function(...) {

  # mutation_codes data ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for mutation_codes."), fill = TRUE)
  mutation_codes <- synapse_read_all_feather_files("syn22131021") %>%
    dplyr::filter(!is.na(code)) %>%
    dplyr::distinct(code) %>%
    dplyr::arrange(code)
  cat(crayon::blue("Imported feather files for mutation_codes."), fill = TRUE)

  # mutation_codes table ---------------------------------------------------
  cat(crayon::magenta("Building mutation_codes table."), fill = TRUE)
  table_written <- mutation_codes %>% iatlas.data::replace_table("mutation_codes")
  cat(crayon::blue("Built mutation_codes table. (", nrow(mutation_codes), "rows )"), fill = TRUE, sep = " ")

}
