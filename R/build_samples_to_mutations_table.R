build_samples_to_mutations_table <- function() {

  # samples_to_mutations import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for samples_to_mutations."), fill = TRUE)
  samples_to_mutations <- synapse_read_all_feather_files("syn22140071")
  cat(crayon::blue("Imported feather files for samples_to_mutations."), fill = TRUE)

  # samples_to_mutations column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring samples_to_mutations have all the correct columns and no dupes."), fill = TRUE)
  samples_to_mutations <- samples_to_mutations %>%
    dplyr::bind_rows(dplyr::tibble(
      sample = character(),
      entrez = numeric(),
      mutation_code = character(),
      mutation_type = character(),
      status = character()
    )) %>%
    dplyr::filter(!is.na(entrez) & !is.na(sample)) %>%
    dplyr::distinct(entrez, sample, mutation_code, mutation_type, status)

  gc()

  samples_to_mutations <- samples_to_mutations %>%
    iatlas.data::resolve_df_dupes(keys = c("entrez", "sample", "mutation_code", "mutation_type")) %>%
    dplyr::select(entrez, sample, mutation_code, mutation_type, status) %>%
    dplyr::arrange(entrez, sample, mutation_type, mutation_code)
  cat(crayon::blue("Ensured samples_to_mutations have all the correct columns and no dupes."), fill = TRUE)

  # samples_to_mutations data ---------------------------------------------------
  cat(crayon::magenta("Building samples_to_mutations data.\n\t(These are some large datasets, please be patient as they are read and built.)"), fill = TRUE)
  samples_to_mutations <- samples_to_mutations %>% dplyr::left_join(iatlas.data::get_genes(), by = "entrez")

  samples_to_mutations <- samples_to_mutations %>% dplyr::left_join(
    iatlas.data::get_samples() %>% dplyr::select(sample_id = id, sample = name),
    by = "sample"
  )

  samples_to_mutations <- samples_to_mutations %>% dplyr::left_join(
    iatlas.data::get_mutation_codes() %>% dplyr::rename(mutation_code = code),
    by = "mutation_code"
  )

  samples_to_mutations <- samples_to_mutations %>% dplyr::left_join(
    iatlas.data::read_table("mutation_types") %>%
      dplyr::select(mutation_type_id = id, mutation_type = name),
    by = "mutation_type"
  )

  samples_to_mutations <- samples_to_mutations %>%
    dplyr::distinct(gene_id, sample_id, mutation_code_id, mutation_type_id, status)

  samples_to_mutations <- samples_to_mutations %>% dplyr::left_join(
    iatlas.data::read_table("mutations") %>% dplyr::rename(mutation_id = id),
    by = c("gene_id", "mutation_code_id", "mutation_type_id")
  )

  samples_to_mutations <- samples_to_mutations %>%
    dplyr::distinct(sample_id, mutation_id, status)
  cat(crayon::blue("Built samples_to_mutations data."), fill = TRUE)

  # samples_to_mutations table ---------------------------------------------------
  cat(crayon::magenta("Building samples_to_mutations table."), fill = TRUE)
  table_written <- samples_to_mutations %>% iatlas.data::replace_table("samples_to_mutations")
  cat(crayon::blue("Built samples_to_mutations table. (", nrow(samples_to_mutations), "rows )"), fill = TRUE)

}
