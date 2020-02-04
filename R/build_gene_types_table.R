build_gene_types_table <- function() {

  cat(crayon::magenta("Importing feather files for gene_types."), fill = TRUE)
  gene_types <- read_iatlas_data_file(get_feather_file_folder(), "gene_types") %>%
    dplyr::distinct(name, display) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Imported feather files for gene_types."), fill = TRUE)

  cat(crayon::magenta("Building gene_types table."), fill = TRUE)
  table_written <- gene_types %>% iatlas.data::write_table_ts("gene_types")
  cat(crayon::blue("Built gene_types table. (", nrow(gene_types), "rows )"), fill = TRUE, sep = " ")

  # cat(crayon::magenta("Building mutation_codes_to_gene_types data."), fill = TRUE)
  # mutation_codes_to_gene_types <- iatlas.data::read_table("mutation_codes") %>%
  #   dplyr::rename(mutation_code_id = id) %>%
  #   tibble::add_column(type = "driver_mutation" %>% as.character()) %>%
  #   dplyr::left_join(iatlas.data::read_table("gene_types"), by = c("type" = "name")) %>%
  #   dplyr::rename(type_id = id) %>%
  #   dplyr::distinct(mutation_code_id, type_id)
  # cat(crayon::blue("Built mutation_codes_to_gene_types data (", nrow(mutation_codes), "rows )"), fill = TRUE, sep = " ")
  #
  # cat(crayon::magenta("Building mutation_codes_to_gene_types table."), fill = TRUE)
  # table_written <- mutation_codes_to_gene_types %>% iatlas.data::write_table_ts("mutation_codes_to_gene_types")
  # cat(crayon::blue("Built mutation_codes_to_gene_types table. (", nrow(mutation_codes_to_gene_types), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building gene_families data."), fill = TRUE)
  gene_families <- genes %>% iatlas.data::rebuild_gene_relational_data("gene_family")
  cat(crayon::blue("Built gene_families data."), fill = TRUE)

  cat(crayon::magenta("Building gene_families table."), fill = TRUE)
  table_written <- gene_families %>% iatlas.data::write_table_ts("gene_families")
  cat(crayon::blue("Built gene_families table. (", nrow(gene_families), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building gene_functions data."), fill = TRUE)
  gene_functions <- genes %>% iatlas.data::rebuild_gene_relational_data("gene_function")
  cat(crayon::blue("Built gene_functions data."), fill = TRUE)

  cat(crayon::magenta("Building gene_functions table."), fill = TRUE)
  table_written <- gene_functions %>% iatlas.data::write_table_ts("gene_functions")
  cat(crayon::blue("Built gene_functions table. (", nrow(gene_functions), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building immune_checkpoints data."), fill = TRUE)
  immune_checkpoints <- genes %>% iatlas.data::rebuild_gene_relational_data("immune_checkpoint")
  cat(crayon::blue("Built immune_checkpoints data."), fill = TRUE)

  cat(crayon::magenta("Building immune_checkpoints table."), fill = TRUE)
  table_written <- immune_checkpoints %>% iatlas.data::write_table_ts("immune_checkpoints")
  cat(crayon::blue("Built immune_checkpoints table. (", nrow(immune_checkpoints), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building node_types data."), fill = TRUE)
  node_types <- genes %>% iatlas.data::rebuild_gene_relational_data("node_type")
  cat(crayon::blue("Built node_types data."), fill = TRUE)

  cat(crayon::magenta("Building node_types table."), fill = TRUE)
  table_written <- node_types %>% iatlas.data::write_table_ts("node_types")
  cat(crayon::blue("Built node_types table. (", nrow(node_types), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Built pathways data."), fill = TRUE)
  pathways <- genes %>% iatlas.data::rebuild_gene_relational_data("pathway")
  cat(crayon::blue("Built pathways data."), fill = TRUE)

  cat(crayon::magenta("Built pathways table."), fill = TRUE)
  table_written <- pathways %>% iatlas.data::write_table_ts("pathways")
  cat(crayon::blue("Built pathways table. (", nrow(pathways), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building super_categories data."), fill = TRUE)
  super_categories <- genes %>% iatlas.data::rebuild_gene_relational_data("super_category")
  cat(crayon::blue("Built super_categories data."), fill = TRUE)

  cat(crayon::magenta("Building super_categories table."), fill = TRUE)
  table_written <- super_categories %>% iatlas.data::write_table_ts("super_categories")
  cat(crayon::blue("Built super_categories table. (", nrow(super_categories), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Built therapy_types data."), fill = TRUE)
  therapy_types <- genes %>% iatlas.data::rebuild_gene_relational_data("therapy_type")
  cat(crayon::blue("Built therapy_types data."), fill = TRUE)

  cat(crayon::magenta("Built therapy_types table."), fill = TRUE)
  table_written <- therapy_types %>% iatlas.data::write_table_ts("therapy_types")
  cat(crayon::blue("Built therapy_types table. (", nrow(therapy_types), "rows )"), fill = TRUE, sep = " ")

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

  cat(crayon::magenta("Building genes table."), fill = TRUE)
  table_written <- genes %>% iatlas.data::write_table_ts("genes")
  cat(crayon::blue("Built genes table. (", nrow(genes), "rows )"), fill = TRUE, sep = " ")

  # Clean up.
  cat("Cleaned up.", fill = TRUE)
  gc()

  # cat(crayon::magenta("Building genes_to_types data."), fill = TRUE)
  # genes <- iatlas.data::read_table("genes") %>% dplyr::select(id, hgnc)
  # gene_types <- iatlas.data::read_table("gene_types")
  #
  # # Collect the ids of the 3 gene_types.
  # driver_mutation_id <- gene_types %>% dplyr::filter(name == "driver_mutation") %>% .[["id"]]
  # immunomodulator_id <- gene_types %>% dplyr::filter(name == "immunomodulator") %>% .[["id"]]
  # io_target_id <- gene_types %>% dplyr::filter(name == "io_target") %>% .[["id"]]
  # ecn_id <- gene_types %>% dplyr::filter(name == "extra_cellular_network") %>% .[["id"]]
  #
  # driver_mutations <- driver_mutations %>% tibble::add_column(type_id = driver_mutation_id %>% as.integer)
  # ecns <- ecns %>% dplyr::distinct(gene) %>% tibble::add_column(type_id = ecn_id %>% as.integer)
  # immunomodulator_expr <- immunomodulator_expr %>% tibble::add_column(type_id = immunomodulator_id %>% as.integer)
  # immunomodulators <- immunomodulators %>% dplyr::distinct(gene) %>% tibble::add_column(type_id = immunomodulator_id %>% as.integer)
  # io_target_expr <- io_target_expr %>% tibble::add_column(type_id = io_target_id %>% as.integer)
  #
  # genes_to_types <- driver_mutations %>%
  #   dplyr::bind_rows(ecns, immunomodulators, immunomodulator_expr, io_target_expr) %>%
  #   dplyr::inner_join(genes, by = c("gene" = "hgnc")) %>%
  #   dplyr::rename(gene_id = id) %>%
  #   dplyr::distinct(gene_id, type_id) %>%
  #   dplyr::arrange(gene_id, type_id)
  # cat(crayon::blue("Build genes_to_types data."), fill = TRUE)
  #
  # cat(crayon::magenta("Building genes_to_types table."), fill = TRUE)
  # table_written <- genes_to_types %>% iatlas.data::write_table_ts("genes_to_types")
  # cat(crayon::blue("Built genes_to_types table. (", nrow(genes_to_types), "rows )"), fill = TRUE, sep = " ")
}
