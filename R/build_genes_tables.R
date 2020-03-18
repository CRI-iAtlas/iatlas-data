build_genes_tables <- function() {

  # genes import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for genes."), fill = TRUE)
  genes <- iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "genes")
  cat(crayon::blue("Imported feather files for genes."), fill = TRUE)

  # genes column fix ---------------------------------------------------
  cat(crayon::magenta("Ensuring genes have all the correct columns and no dupes."), fill = TRUE)
  # TODO: This should depend on entrez.
  genes <- genes %>%
    dplyr::bind_rows(dplyr::tibble(
      entrez = numeric(),
      hgnc = character(),
      description = character(),
      friendly_name = character(),
      io_landscape_name = character(),
      gene_family = character(),
      gene_function = character(),
      immune_checkpoint = character(),
      node_type = character(),
      pathway = character(),
      references = character(),
      super_category = character(),
      therapy_type = character()
    )) %>%
    dplyr::filter(!is.na(entrez)) %>%
    dplyr::distinct(entrez, hgnc, description, friendly_name, io_landscape_name, gene_family, gene_function, immune_checkpoint, node_type, pathway, references, super_category, therapy_type) %>%
    dplyr::mutate_at(dplyr::vars(entrez), as.numeric) %>%
    dplyr::mutate_at(dplyr::vars(friendly_name), as.character) %>%
    iatlas.data::resolve_df_dupes(keys = c("entrez")) %>%
    dplyr::distinct(entrez, hgnc, description, friendly_name, io_landscape_name, gene_family, gene_function, immune_checkpoint, node_type, pathway, references, super_category, therapy_type) %>%
    dplyr::arrange(entrez)
  cat(crayon::blue("Ensured genes have all the correct columns and no dupes."), fill = TRUE)

  # entrez fix ---------------------------------------------------
  cat(crayon::magenta("Ensure genes have the correct entrez.\n\t(Please be patient, this may take a little while.)"), fill = TRUE)
  genes <- genes %>%
    dplyr::left_join(
      iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "gene_ids.feather") %>%
        dplyr::select(hgnc, real_entrez = entrez),
      by = "hgnc"
    ) %>%
    dplyr::mutate(entrez = ifelse(!is.na(real_entrez), real_entrez, entrez))

  # gene_families data ---------------------------------------------------
  cat(crayon::magenta("Building gene_families data."), fill = TRUE)
  gene_families <- genes %>% iatlas.data::rebuild_gene_relational_data("gene_family")
  cat(crayon::blue("Built gene_families data."), fill = TRUE)

  # gene_families table ---------------------------------------------------
  cat(crayon::magenta("Building gene_families table."), fill = TRUE)
  table_written <- gene_families %>% iatlas.data::replace_table("gene_families")
  cat(crayon::blue("Built gene_families table. (", nrow(gene_families), "rows )"), fill = TRUE, sep = " ")

  # gene_functions data ---------------------------------------------------
  cat(crayon::magenta("Building gene_functions data."), fill = TRUE)
  gene_functions <- genes %>% iatlas.data::rebuild_gene_relational_data("gene_function")
  cat(crayon::blue("Built gene_functions data."), fill = TRUE)

  # gene_functions table ---------------------------------------------------
  cat(crayon::magenta("Building gene_functions table."), fill = TRUE)
  table_written <- gene_functions %>% iatlas.data::replace_table("gene_functions")
  cat(crayon::blue("Built gene_functions table. (", nrow(gene_functions), "rows )"), fill = TRUE, sep = " ")

  # immune_checkpoints data ---------------------------------------------------
  cat(crayon::magenta("Building immune_checkpoints data."), fill = TRUE)
  immune_checkpoints <- genes %>% iatlas.data::rebuild_gene_relational_data("immune_checkpoint")
  cat(crayon::blue("Built immune_checkpoints data."), fill = TRUE)

  # immune_checkpoints table ---------------------------------------------------
  cat(crayon::magenta("Building immune_checkpoints table."), fill = TRUE)
  table_written <- immune_checkpoints %>% iatlas.data::replace_table("immune_checkpoints")
  cat(crayon::blue("Built immune_checkpoints table. (", nrow(immune_checkpoints), "rows )"), fill = TRUE, sep = " ")

  # node_types data ---------------------------------------------------
  cat(crayon::magenta("Building node_types data."), fill = TRUE)
  node_types <- genes %>% iatlas.data::rebuild_gene_relational_data("node_type")
  cat(crayon::blue("Built node_types data."), fill = TRUE)

  # node_types table ---------------------------------------------------
  cat(crayon::magenta("Building node_types table."), fill = TRUE)
  table_written <- node_types %>% iatlas.data::replace_table("node_types")
  cat(crayon::blue("Built node_types table. (", nrow(node_types), "rows )"), fill = TRUE, sep = " ")

  # pathways data ---------------------------------------------------
  cat(crayon::magenta("Built pathways data."), fill = TRUE)
  pathways <- genes %>% iatlas.data::rebuild_gene_relational_data("pathway")
  cat(crayon::blue("Built pathways data."), fill = TRUE)

  # pathways table ---------------------------------------------------
  cat(crayon::magenta("Built pathways table."), fill = TRUE)
  table_written <- pathways %>% iatlas.data::replace_table("pathways")
  cat(crayon::blue("Built pathways table. (", nrow(pathways), "rows )"), fill = TRUE, sep = " ")

  # super_categories data ---------------------------------------------------
  cat(crayon::magenta("Building super_categories data."), fill = TRUE)
  super_categories <- genes %>% iatlas.data::rebuild_gene_relational_data("super_category")
  cat(crayon::blue("Built super_categories data."), fill = TRUE)

  # super_categories table ---------------------------------------------------
  cat(crayon::magenta("Building super_categories table."), fill = TRUE)
  table_written <- super_categories %>% iatlas.data::replace_table("super_categories")
  cat(crayon::blue("Built super_categories table. (", nrow(super_categories), "rows )"), fill = TRUE, sep = " ")

  # therapy_types data ---------------------------------------------------
  cat(crayon::magenta("Built therapy_types data."), fill = TRUE)
  therapy_types <- genes %>% iatlas.data::rebuild_gene_relational_data("therapy_type")
  cat(crayon::blue("Built therapy_types data."), fill = TRUE)

  # therapy_types table ---------------------------------------------------
  cat(crayon::magenta("Built therapy_types table."), fill = TRUE)
  table_written <- therapy_types %>% iatlas.data::replace_table("therapy_types")
  cat(crayon::blue("Built therapy_types table. (", nrow(therapy_types), "rows )"), fill = TRUE, sep = " ")

  # genes data ---------------------------------------------------
  cat(crayon::magenta("Building genes data."), fill = TRUE)
  cat(crayon::cyan(" - Adding gene_family ids."), fill = TRUE)
  genes <- genes %>%
    dplyr::left_join(iatlas.data::read_table("gene_families"), by = c("gene_family" = "name")) %>%
    dplyr::rename(gene_family_id = id)
  cat(crayon::cyan(" - Adding gene_function ids."), fill = TRUE)
  genes <- genes %>%
    dplyr::left_join(iatlas.data::read_table("gene_functions"), by = c("gene_function" = "name")) %>%
    dplyr::rename(gene_function_id = id)
  cat(crayon::cyan(" - Adding immune_checkpoint ids."), fill = TRUE)
  genes <- genes %>%
    dplyr::left_join(iatlas.data::read_table("immune_checkpoints"), by = c("immune_checkpoint" = "name")) %>%
    dplyr::rename(immune_checkpoint_id = id)
  cat(crayon::cyan(" - Adding node_type ids."), fill = TRUE)
  genes <- genes %>%
    dplyr::left_join(iatlas.data::read_table("node_types"), by = c("node_type" = "name")) %>%
    dplyr::rename(node_type_id = id)
  cat(crayon::cyan(" - Adding pathway ids."), fill = TRUE)
  genes <- genes %>%
    dplyr::left_join(iatlas.data::read_table("pathways"), by = c("pathway" = "name")) %>%
    dplyr::rename(pathway_id = id)
  cat(crayon::cyan(" - Adding super_category ids."), fill = TRUE)
  genes <- genes %>%
    dplyr::left_join(iatlas.data::read_table("super_categories"), by = c("super_category" = "name")) %>%
    dplyr::rename(super_cat_id = id)
  cat(crayon::cyan(" - Adding therapy_type ids."), fill = TRUE)
  genes <- genes %>%
    dplyr::left_join(iatlas.data::read_table("therapy_types"), by = c("therapy_type" = "name")) %>%
    dplyr::rename(therapy_type_id = id) %>%
    dplyr::distinct(entrez, hgnc, description, friendly_name, gene_family_id, gene_function_id, immune_checkpoint_id, node_type_id, io_landscape_name, pathway_id, references, super_cat_id, therapy_type_id)
  cat(crayon::blue("Built genes data."), fill = TRUE)

  # genes table ---------------------------------------------------
  cat(crayon::magenta("Building genes table."), fill = TRUE)
  table_written <- genes %>% iatlas.data::replace_table("genes")
  cat(crayon::blue("Built genes table. (", nrow(genes), "rows )"), fill = TRUE, sep = " ")

}
