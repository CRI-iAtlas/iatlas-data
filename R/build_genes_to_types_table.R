build_genes_to_types_table <- function() {

  cat(crayon::magenta("Importing feather files for genes_to_types."), fill = TRUE)
  genes_to_types <- read_iatlas_data_file(
    get_feather_file_folder(),
    "relationships/genes_to_types"
  ) %>%
    dplyr::distinct(entrez, hgnc, gene_type) %>%
    dplyr::filter((!is.na(entrez) | !is.na(hgnc)) & !is.na(gene_type)) %>%
    dplyr::arrange(entrez, hgnc, gene_type)
  cat(crayon::blue("Imported feather files for genes_to_types."), fill = TRUE)

  cat(crayon::magenta("Building genes_to_types data."), fill = TRUE)
  # This should be joined by entrez.
  genes_to_types <- genes_to_types %>% dplyr::left_join(get_genes(), by = "hgnc")

  genes_to_types <- genes_to_types %>% dplyr::left_join(
    iatlas.data::read_table("gene_types") %>%
      dplyr::as_tibble() %>%
      dplyr::select(type_id = id, gene_type = name),
    by = "gene_type"
  )

  genes_to_types <- genes_to_types %>%
    dplyr::distinct(gene_id, type_id) %>%
    dplyr::arrange(gene_id, type_id)
  cat(crayon::blue("Build genes_to_types data."), fill = TRUE)

  cat(crayon::magenta("Building genes_to_types table."), fill = TRUE)
  table_written <- genes_to_types %>% iatlas.data::replace_table("genes_to_types")
  cat(crayon::blue("Built genes_to_types table. (", nrow(genes_to_types), "rows )"), fill = TRUE, sep = " ")

}
