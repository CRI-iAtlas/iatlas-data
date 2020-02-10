build_gene_types_table <- function() {

  # gene_types import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for gene_types."), fill = TRUE)
  gene_types <- iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "gene_types")
  cat(crayon::blue("Imported feather files for gene_types."), fill = TRUE)

  # gene_types column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring gene_types have all the correct columns and no dupes."), fill = TRUE)
  gene_types <- gene_types %>%
    dplyr::bind_rows(dplyr::tibble(
      name = character(),
      display = character()
    )) %>%
    dplyr::distinct(name, display) %>%
    dplyr::filter(!is.na(name)) %>%
    iatlas.data::resolve_df_dupes(keys = c("name")) %>%
    dplyr::select(name, display) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Ensured gene_types have all the correct columns and no dupes."), fill = TRUE)

  # gene_types table ---------------------------------------------------
  cat(crayon::magenta("Building gene_types table."), fill = TRUE)
  table_written <- gene_types %>% iatlas.data::replace_table("gene_types")
  cat(crayon::blue("Built gene_types table. (", nrow(gene_types), "rows )"), fill = TRUE, sep = " ")

}
