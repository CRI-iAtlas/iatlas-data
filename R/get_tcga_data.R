get_tcga_driver_mutations <- function() {
  driver_mutations <- iatlas.data::read_iatlas_data_file("feather_files", "SQLite_data/driver_mutations")

  driver_mutations <- driver_mutations %>%
    dplyr::filter(!is.na(gene)) %>%
    dplyr::mutate(hgnc = ifelse(!is.na(gene), iatlas.data::trim_hgnc(gene), NA)) %>%
    dplyr::mutate(mutation_code = ifelse(!is.na(gene), iatlas.data::get_mutation_code(gene), NA)) %>%
    dplyr::left_join(iatlas.data::get_human_gene_ids_cached(), by = "hgnc")

  no_entrez <- driver_mutations %>%
    dplyr::filter(is.na(entrez)) %>%
    dplyr::select(-entrez) %>%
    dplyr::left_join(iatlas.data::get_gene_ids(), by = "hgnc")

  driver_mutations <- driver_mutations %>%
    dplyr::filter(!is.na(entrez)) %>%
    dplyr::bind_rows(no_entrez) %>%
    dplyr::distinct(
      entrez,
      hgnc,
      mutation_code,
      tcga_study = TCGA_Study,
      tcga_subtype = TCGA_Subtype,
      immune_subtype = Immune_Subtype,
      sample,
      status
    ) %>%
    dplyr::arrange(entrez, mutation_code, tcga_study, tcga_subtype, immune_subtype)

  return(driver_mutations)
}
