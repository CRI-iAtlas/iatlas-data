build_mutation_codes_table <- function() {

  # mutation_codes data ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for mutation_codes."), fill = TRUE)
  mutation_codes <- iatlas.data::read_iatlas_data_file(
    iatlas.data::get_feather_file_folder(),
    "mutation_codes"
  ) %>%
    dplyr::distinct(code) %>%
    dplyr::filter(!is.na(code)) %>%
    dplyr::arrange(code)
  cat(crayon::blue("Imported feather files for mutation_codes."), fill = TRUE)

  # mutation_codes table ---------------------------------------------------
  cat(crayon::magenta("Building mutation_codes table."), fill = TRUE)
  table_written <- mutation_codes %>% iatlas.data::replace_table("mutation_codes")
  cat(crayon::blue("Built mutation_codes table. (", nrow(mutation_codes), "rows )"), fill = TRUE, sep = " ")

}
