old_build_genes_tables <- function() {
  default_mutation_code <- "(NS)"

  cat(crayon::magenta("Importing driver mutation feather files for genes"), fill = TRUE)
  driver_mutations <- iatlas.data::get_tcga_driver_mutation_genes()
  cat(crayon::blue("Imported driver mutation feather files for genes"), fill = TRUE)

  cat(crayon::magenta("Importing immunomodulators feather files for genes"), fill = TRUE)
  immunomodulator_expr <- iatlas.data::get_tcga_immunomodulator_expr_genes()
  immunomodulators <- iatlas.data::get_tcga_immunodulator_genes()
  cat(crayon::blue("Imported immunomodulators feather files for genes"), fill = TRUE)

  cat(crayon::magenta("Importing io_target feather files for genes"), fill = TRUE)
  io_target_expr <- iatlas.data::get_tcga_io_target_expr_genes()
  io_targets <- iatlas.data::get_tcga_io_target_genes()
  cat(crayon::blue("Imported io_target feather files for genes"), fill = TRUE)

  cat(crayon::magenta("Importing extra cellular network (ecn) feather files for genes"), fill = TRUE)
  ecns <- iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "ecn_genes.feather") %>%
    dplyr::select(-c("entrez")) %>%
    dplyr::arrange(hgnc)
  cat(crayon::blue("Imported extra cellular network (ecn) feather files for genes."), fill = TRUE)

  cat(crayon::magenta("Building mutation_codes data."), fill = TRUE)
  mutation_codes <- driver_mutations %>%
    dplyr::distinct(hgnc) %>%
    dplyr::mutate(code = ifelse(!is.na(hgnc), iatlas.data::old_get_mutation_code(hgnc), NA)) %>%
    dplyr::filter(!is.na(code)) %>%
    dplyr::add_row(code = default_mutation_code) %>%
    dplyr::distinct(code) %>%
    dplyr::arrange(code)
  cat(crayon::blue("Built mutation_codes data."), fill = TRUE)

  cat(crayon::magenta("Building mutation_codes table."), fill = TRUE)
  table_written <- mutation_codes %>% iatlas.data::replace_table("mutation_codes")
  cat(crayon::blue("Built mutation_codes table. (", nrow(mutation_codes), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building mutation_types data."), fill = TRUE)
  mutation_types <- dplyr::tibble(name = "driver_mutation", display = "Driver Mutation")
  cat(crayon::blue("Built mutation_types data."), fill = TRUE)

  cat(crayon::magenta("Building mutation_types table."), fill = TRUE)
  table_written <- mutation_types %>% iatlas.data::replace_table("mutation_types")
  cat(crayon::blue("Built mutation_types table. (", nrow(mutation_types), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Binding gene expr data."), fill = TRUE)
  all_genes_expr <- driver_mutations %>%
    dplyr::bind_rows(immunomodulator_expr, io_target_expr) %>%
    dplyr::mutate(hgnc = ifelse(!is.na(hgnc), iatlas.data::trim_hgnc(hgnc), NA)) %>%
    dplyr::distinct(hgnc) %>%
    dplyr::arrange(hgnc)
  cat(crayon::blue("Bound gene expr data."), fill = TRUE)

  cat(crayon::magenta("Binding ecn, immunomodulators, and io_targets."), fill = TRUE)
  immunomodulators <- immunomodulators %>% dplyr::anti_join(io_targets, by = "hgnc")
  all_genes <- dplyr::bind_rows(immunomodulators, io_targets)
  all_genes <- ecns %>%
    dplyr::select(-c("type")) %>%
    dplyr::full_join(all_genes, by = "hgnc", suffix = c("",".y")) %>%
    dplyr::select(-dplyr::ends_with(".y")) %>%
    dplyr::distinct(hgnc, .keep_all = TRUE)
  cat(crayon::blue("Bound ecn, immunomodulators, and io_targets."), fill = TRUE)

  cat(crayon::magenta("Building all gene data.\n\t(Please be patient, this may take a little while.)"), fill = TRUE)
  all_genes <- all_genes_expr %>%
    dplyr::full_join(all_genes, by = "hgnc") %>%
    dplyr::arrange(hgnc)
  all_genes <- all_genes %>% dplyr::left_join(
    iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "gene_ids.feather"),
    by = "hgnc"
  )
  all_genes <- all_genes %>% dplyr::left_join(
    iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "SQLite_data/missing_genes.feather"),
    by = "hgnc"
  ) %>%
    dplyr::mutate(
      description = ifelse(is.na(description.x), description.y, description.x),
      entrez = ifelse(is.na(entrez.x), entrez.y, entrez.x)
    ) %>%
    dplyr::select(-c("description.x", "description.y", "entrez.y", "entrez.x"))
  cat(crayon::blue("Built all gene data."), fill = TRUE)

  # Clean up.
  rm(all_genes_expr)
  rm(io_targets)
  cat("Cleaned up.", fill = TRUE)
  gc()

  cat(crayon::magenta("Building gene_types data."), fill = TRUE)
  gene_types <- dplyr::tibble(
    name = c("immunomodulator", "io_target", "extra_cellular_network"),
    display = c("Immunomodulator", "IO Target", "Extra Cellular Network")
  )
  cat(crayon::blue("Built gene_types data."), fill = TRUE)

  cat(crayon::magenta("Building gene_types table."), fill = TRUE)
  table_written <- gene_types %>% iatlas.data::replace_table("gene_types")
  cat(crayon::blue("Built gene_types table. (", nrow(gene_types), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building gene_families data."), fill = TRUE)
  gene_families <- all_genes %>% iatlas.data::rebuild_gene_relational_data("gene_family", "name")
  cat(crayon::blue("Built gene_families data."), fill = TRUE)

  cat(crayon::magenta("Building gene_families table."), fill = TRUE)
  table_written <- gene_families %>% iatlas.data::replace_table("gene_families")
  cat(crayon::blue("Built gene_families table. (", nrow(gene_families), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building gene_functions data."), fill = TRUE)
  gene_functions <- all_genes %>% iatlas.data::rebuild_gene_relational_data("gene_function", "name")
  cat(crayon::blue("Built gene_functions data."), fill = TRUE)

  cat(crayon::magenta("Building gene_functions table."), fill = TRUE)
  table_written <- gene_functions %>% iatlas.data::replace_table("gene_functions")
  cat(crayon::blue("Built gene_functions table. (", nrow(gene_functions), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building immune_checkpoints data."), fill = TRUE)
  immune_checkpoints <- all_genes %>% iatlas.data::rebuild_gene_relational_data("immune_checkpoint", "name")
  cat(crayon::blue("Built immune_checkpoints data."), fill = TRUE)

  cat(crayon::magenta("Building immune_checkpoints table."), fill = TRUE)
  table_written <- immune_checkpoints %>% iatlas.data::replace_table("immune_checkpoints")
  cat(crayon::blue("Built immune_checkpoints table. (", nrow(immune_checkpoints), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building node_types data."), fill = TRUE)
  node_types <- all_genes %>% iatlas.data::rebuild_gene_relational_data("node_type", "name")
  cat(crayon::blue("Built node_types data."), fill = TRUE)

  cat(crayon::magenta("Building node_types table."), fill = TRUE)
  table_written <- node_types %>% iatlas.data::replace_table("node_types")
  cat(crayon::blue("Built node_types table. (", nrow(node_types), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Built pathways data."), fill = TRUE)
  pathways <- all_genes %>% iatlas.data::rebuild_gene_relational_data("pathway", "name")
  cat(crayon::blue("Built pathways data."), fill = TRUE)

  cat(crayon::magenta("Built pathways table."), fill = TRUE)
  table_written <- pathways %>% iatlas.data::replace_table("pathways")
  cat(crayon::blue("Built pathways table. (", nrow(pathways), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building super_categories data."), fill = TRUE)
  super_categories <- all_genes %>% iatlas.data::rebuild_gene_relational_data("super_category", "name")
  cat(crayon::blue("Built super_categories data."), fill = TRUE)

  cat(crayon::magenta("Building super_categories table."), fill = TRUE)
  table_written <- super_categories %>% iatlas.data::replace_table("super_categories")
  cat(crayon::blue("Built super_categories table. (", nrow(super_categories), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Built therapy_types data."), fill = TRUE)
  therapy_types <- all_genes %>% iatlas.data::rebuild_gene_relational_data("therapy_type", "name")
  cat(crayon::blue("Built therapy_types data."), fill = TRUE)

  cat(crayon::magenta("Built therapy_types table."), fill = TRUE)
  table_written <- therapy_types %>% iatlas.data::replace_table("therapy_types")
  cat(crayon::blue("Built therapy_types table. (", nrow(therapy_types), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building genes data."), fill = TRUE)
  cat(crayon::cyan(" - Adding gene_family ids."), fill = TRUE)
  genes <- all_genes %>%
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

  cat(crayon::magenta("Building genes table."), fill = TRUE)
  table_written <- genes %>% iatlas.data::replace_table("genes")
  cat(crayon::blue("Built genes table. (", nrow(genes), "rows )"), fill = TRUE, sep = " ")

  # Clean up.
  cat("Cleaned up.", fill = TRUE)
  gc()

  cat(crayon::magenta("Building genes_to_types data."), fill = TRUE)
  gene_types <- iatlas.data::read_table("gene_types")

  # Collect the ids of the 3 gene_types.
  immunomodulator_id <- gene_types %>% dplyr::filter(name == "immunomodulator") %>% .[["id"]]
  io_target_id <- gene_types %>% dplyr::filter(name == "io_target") %>% .[["id"]]
  ecn_id <- gene_types %>% dplyr::filter(name == "extra_cellular_network") %>% .[["id"]]

  ecns <- ecns %>% dplyr::distinct(hgnc) %>% tibble::add_column(type_id = ecn_id %>% as.integer)
  immunomodulator_expr <- immunomodulator_expr %>% tibble::add_column(type_id = immunomodulator_id %>% as.integer)
  immunomodulators <- immunomodulators %>% dplyr::distinct(hgnc) %>% tibble::add_column(type_id = immunomodulator_id %>% as.integer)
  io_target_expr <- io_target_expr %>% tibble::add_column(type_id = io_target_id %>% as.integer)

  genes_to_types <- ecns %>%
    dplyr::bind_rows(immunomodulators, immunomodulator_expr, io_target_expr) %>%
    dplyr::mutate(hgnc = ifelse(!is.na(hgnc), iatlas.data::trim_hgnc(hgnc), NA)) %>%
    dplyr::left_join(old_read_genes(), by = "hgnc") %>%
    dplyr::distinct(gene_id, type_id) %>%
    dplyr::arrange(gene_id, type_id)
  cat(crayon::blue("Build genes_to_types data."), fill = TRUE)

  cat(crayon::magenta("Building genes_to_types table."), fill = TRUE)
  table_written <- genes_to_types %>% iatlas.data::replace_table("genes_to_types")
  cat(crayon::blue("Built genes_to_types table. (", nrow(genes_to_types), "rows )"), fill = TRUE, sep = " ")
}
