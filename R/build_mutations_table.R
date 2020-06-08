build_mutations_table <- function() {

  # mutations import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for mutations."), fill = TRUE)
  mutations <- synapse_read_all_feather_files("syn22139702")
  cat(crayon::blue("Imported feather files for mutations."), fill = TRUE)

  # mutations column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring mutations have all the correct columns and no dupes."), fill = TRUE)
  mutations <- mutations %>%
    dplyr::bind_rows(dplyr::tibble(
      entrez = numeric(),
      code = character(),
      type = character()
    )) %>%
    dplyr::filter(!is.na(entrez) & !is.na(code)) %>%
    dplyr::distinct(entrez, code, type)

  gc()

  mutations <- mutations %>%
    iatlas.data::resolve_df_dupes(keys = c("entrez", "code", "type")) %>%
    dplyr::select(entrez, code, type) %>%
    dplyr::arrange(entrez, type, code)
  cat(crayon::blue("Ensured mutations have all the correct columns and no dupes."), fill = TRUE)

  # mutations data ---------------------------------------------------
  cat(crayon::magenta("Building mutations data.\n\t(These are some large datasets, please be patient as they are read and built.)"), fill = TRUE)
  mutations <- mutations %>% dplyr::left_join(iatlas.data::get_genes(), by = "entrez")

  mutations <- mutations %>% dplyr::left_join(iatlas.data::get_mutation_codes(), by = "code")

  mutations <- mutations %>% dplyr::left_join(
    iatlas.data::read_table("mutation_types") %>%
      dplyr::select(mutation_type_id = id, type = name),
    by = "type"
  )

  mutations <- mutations %>% dplyr::distinct(gene_id, mutation_code_id, mutation_type_id)
  cat(crayon::blue("Built mutations data."), fill = TRUE)

  # mutations table ---------------------------------------------------
  cat(crayon::magenta("Building mutations table."), fill = TRUE)
  table_written <- mutations %>% iatlas.data::replace_table("mutations")
  cat(crayon::blue("Built mutations table. (", nrow(mutations), "rows )"), fill = TRUE)

}
