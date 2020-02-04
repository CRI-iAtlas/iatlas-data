build_mutation_codes_table <- function() {

  cat(crayon::magenta("Importing feather files for mutation_codes."), fill = TRUE)
  mutation_codes <- read_iatlas_data_file(get_feather_file_folder(), "mutation_codes") %>%
    dplyr::distinct(code) %>%
    dplyr::arrange(code)
  cat(crayon::blue("Imported feather files for mutation_codes."), fill = TRUE)

  cat(crayon::magenta("Building mutation_codes table."), fill = TRUE)
  table_written <- mutation_codes %>% iatlas.data::write_table_ts("mutation_codes")
  cat(crayon::blue("Built mutation_codes table. (", nrow(mutation_codes), "rows )"), fill = TRUE, sep = " ")

}
