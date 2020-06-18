build_publications_to_genes_table <- function() {

  # publications_to_genes import ---------------------------------------------------
  cat(crayon::magenta("Importing files for publications_to_genes"), fill = TRUE)
  publications_to_genes <- synapse_read_all_feather_files("syn22168383")
  cat(crayon::blue("Imported files for publications_to_genes"), fill = TRUE)

  # publications_to_genes column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring publications_to_genes have all the correct columns and no dupes."), fill = TRUE)
  publications_to_genes  <- publications_to_genes %>%
    dplyr::mutate_at(c("pubmed_id", "entrez"), as.integer) %>%
    tidyr::drop_na() %>%
    dplyr::distinct()

  cat(crayon::blue("Ensured publications_to_genes all the correct columns and no dupes."), fill = TRUE)

  # publications_to_genes data ---------------------------------------------------
  cat(crayon::magenta("Building publications_to_genes data."), fill = TRUE)
  publications_to_genes <- publications_to_genes %>%
    dplyr::left_join(iatlas.data::get_publications(), by = "pubmed_id") %>%
    dplyr::left_join(iatlas.data::get_genes(), by = "entrez") %>%
    dplyr::select("publication_id", "gene_id")
  cat(crayon::blue("Built publications_to_genes data."), fill = TRUE)

  # publications_to_genes table ---------------------------------------------------
  cat(crayon::magenta("Building the publications_to_genes table."), fill = TRUE)
  table_written <- publications_to_genes %>% iatlas.data::replace_table("publications_to_genes")
  cat(crayon::blue("Built the publications_to_genes table. (", nrow(publications_to_genes), "rows )"), fill = TRUE, sep = " ")

}
