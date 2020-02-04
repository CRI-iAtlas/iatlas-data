build_gene_types_table <- function() {

  # gene_types import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for gene_types."), fill = TRUE)
  gene_types <- read_iatlas_data_file(get_feather_file_folder(), "gene_types") %>%
    dplyr::distinct(name, .keep_all = TRUE) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Imported feather files for gene_types."), fill = TRUE)

  # gene_types table ---------------------------------------------------
  cat(crayon::magenta("Building gene_types table."), fill = TRUE)
  table_written <- gene_types %>% iatlas.data::write_table_ts("gene_types")
  cat(crayon::blue("Built gene_types table. (", nrow(gene_types), "rows )"), fill = TRUE, sep = " ")

}
