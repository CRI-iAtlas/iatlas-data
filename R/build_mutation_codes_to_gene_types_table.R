build_mutation_codes_to_gene_types_table <- function() {

  # mutation_codes_to_gene_types import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for mutation_codes_to_gene_types."), fill = TRUE)
  mutation_codes_to_gene_types <- read_iatlas_data_file(
    get_feather_file_folder(),
    "relationships/mutation_codes_to_gene_types"
  ) %>%
    dplyr::distinct(code, gene_type) %>%
    dplyr::filter(!is.na(code) & !is.na(gene_type)) %>%
    dplyr::arrange(code, gene_type)
  cat(crayon::blue("Imported feather files for mutation_codes_to_gene_types."), fill = TRUE)

  # mutation_codes_to_gene_types data ---------------------------------------------------
  cat(crayon::magenta("Building mutation_codes_to_gene_types data."), fill = TRUE)
  mutation_codes_to_gene_types <- mutation_codes_to_gene_types %>% dplyr::left_join(
    iatlas.data::read_table("gene_types") %>%
      dplyr::as_tibble() %>%
      dplyr::select(type_id = id, gene_type = name),
    by = "type_id"
  )

  mutation_codes_to_gene_types <- mutation_codes_to_gene_types %>% dplyr::left_join(
    iatlas.data::read_table("mutation_codes") %>%
      dplyr::as_tibble() %>%
      dplyr::select(mutation_code_id = id, code),
    by = "mutation_code_id"
  )
  cat(crayon::blue("Built mutation_codes_to_gene_types data. (", nrow(mutation_codes_to_gene_types), "rows )"), fill = TRUE, sep = " ")

  # mutation_codes_to_gene_types table ---------------------------------------------------
  cat(crayon::magenta("Building mutation_codes_to_gene_types table."), fill = TRUE)
  table_written <- mutation_codes_to_gene_types %>% iatlas.data::write_table_ts("mutation_codes_to_gene_types")
  cat(crayon::blue("Built mutation_codes_to_gene_types table. (", nrow(mutation_codes_to_gene_types), "rows )"), fill = TRUE, sep = " ")

}
