build_genes_tables <- function(feather_file_folder) {

  apply_path <- function(sub_path) {
    paste0(feather_file_folder, "/", sub_path)
  }

  cat(crayon::magenta("Importing driver mutation feather files for genes"), fill = TRUE)
  driver_mutations <- dplyr::bind_rows(
    feather::read_feather(apply_path("SQLite_data/driver_mutations1.feather")),
    feather::read_feather(apply_path("SQLite_data/driver_mutations2.feather")),
    feather::read_feather(apply_path("SQLite_data/driver_mutations3.feather")),
    feather::read_feather(apply_path("SQLite_data/driver_mutations4.feather")),
    feather::read_feather(apply_path("SQLite_data/driver_mutations5.feather"))
  ) %>%
    dplyr::distinct(gene) %>%
    dplyr::arrange(gene)
  cat(crayon::blue("Imported driver mutation feather files for genes"), fill = TRUE)

  cat(crayon::magenta("Importing immunomodulators feather files for genes"), fill = TRUE)
  immunomodulator_expr <- feather::read_feather(
    apply_path("SQLite_data/immunomodulator_expr.feather")
  ) %>%
    dplyr::distinct(gene) %>%
    dplyr::arrange(gene)

  immunomodulators <- feather::read_feather(apply_path("SQLite_data/immunomodulators.feather")) %>%
    dplyr::filter(!is.na(gene)) %>%
    dplyr::rename_at("display2", ~("friendly_name")) %>%
    dplyr::mutate(references = iatlas.data::build_references(reference)) %>%
    dplyr::select(-c("display", "entrez", "reference")) %>%
    dplyr::arrange(gene)
  cat(crayon::blue("Imported immunomodulators feather files for genes"), fill = TRUE)

  cat(crayon::magenta("Importing io_target feather files for genes"), fill = TRUE)
  io_target_expr <- dplyr::bind_rows(
    feather::read_feather(apply_path("SQLite_data/io_target_expr1.feather")),
    feather::read_feather(apply_path("SQLite_data/io_target_expr2.feather")),
    feather::read_feather(apply_path("SQLite_data/io_target_expr3.feather")),
    feather::read_feather(apply_path("SQLite_data/io_target_expr4.feather"))
  ) %>%
    dplyr::distinct(gene) %>%
    dplyr::arrange(gene)

  io_targets <- feather::read_feather(apply_path("SQLite_data/io_targets.feather")) %>%
    dplyr::filter(!is.na(gene)) %>%
    dplyr::distinct(gene, .keep_all = TRUE) %>%
    dplyr::select(-c("entrez")) %>%
    dplyr::rename_at("display2", ~("io_landscape_name")) %>%
    dplyr::mutate(references = iatlas.data::link_to_references(link)) %>%
    dplyr::select(-c("display", "link")) %>%
    dplyr::left_join(immunomodulators, by = "gene",suffix = c("",".y"))  %>%
    dplyr::select(-dplyr::ends_with(".y")) %>%
    dplyr::arrange(gene)
  cat(crayon::blue("Imported io_target feather files for genes"), fill = TRUE)

  cat(crayon::magenta("Importing extra cellular network (ecn) feather files for genes"), fill = TRUE)
  ecns <- feather::read_feather(apply_path("genes/ecn_genes.feather")) %>%
    dplyr::rename_at("hgnc", ~("gene")) %>%
    dplyr::select(-c("entrez")) %>%
    dplyr::arrange(gene)
  cat(crayon::blue("Imported extra cellular network (ecn) feather files for genes."), fill = TRUE)

  cat(crayon::magenta("Building mutation_codes data."), fill = TRUE)
  mutation_codes <- driver_mutations %>%
    dplyr::distinct(gene) %>%
    dplyr::mutate(code = ifelse(!is.na(gene), iatlas.data::get_mutation_code(gene), NA)) %>%
    dplyr::distinct(code) %>%
    dplyr::filter(!is.na(code))
  cat(crayon::blue("Built mutation_codes data."), fill = TRUE)

  cat(crayon::magenta("Building mutation_codes table."), fill = TRUE)
  table_written <- mutation_codes %>% iatlas.data::write_table_ts("mutation_codes")
  cat(crayon::blue("Built mutation_codes table. (", nrow(mutation_codes), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Binding gene expr data."), fill = TRUE)
  all_genes_expr <- driver_mutations %>%
    dplyr::bind_rows(immunomodulator_expr, io_target_expr) %>%
    dplyr::mutate(gene = ifelse(!is.na(gene), iatlas.data::trim_hgnc(gene), NA)) %>%
    dplyr::distinct(gene) %>%
    dplyr::arrange(gene)
  cat(crayon::blue("Bound gene expr data."), fill = TRUE)

  cat(crayon::magenta("Binding ecn, immunomodulators, and io_targets."), fill = TRUE)
  immunomodulators <- immunomodulators %>% dplyr::anti_join(io_targets, by = "gene")
  all_genes <- dplyr::bind_rows(immunomodulators, io_targets)
  all_genes <- ecns %>%
    dplyr::select(-c("type")) %>%
    dplyr::full_join(all_genes, by = "gene",suffix = c("",".y")) %>%
    dplyr::select(-dplyr::ends_with(".y")) %>%
    dplyr::distinct(gene, .keep_all = TRUE)
  cat(crayon::blue("Bound ecn, immunomodulators, and io_targets."), fill = TRUE)

  cat(crayon::magenta("Building all gene data.\n(Please be patient, this may take a little while.)"), fill = TRUE)
  all_genes_expr <- all_genes_expr %>%
    tibble::add_column(
      description = NA %>% as.character,
      friendly_name = NA %>% as.character,
      gene_family = NA %>% as.character,
      gene_function = NA %>% as.character,
      immune_checkpoint = NA %>% as.character,
      io_landscape_name = NA %>% as.character,
      pathway = NA %>% as.character,
      references = NA,
      super_category = NA %>% as.character,
      therapy_type = NA %>% as.character
    ) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      description = iatlas.data::switch_value(.data, "gene", "description", all_genes) %>% as.character(),
      friendly_name = iatlas.data::switch_value(.data, "gene", "friendly_name", all_genes) %>% as.character(),
      gene_family = iatlas.data::switch_value(.data, "gene", "gene_family", all_genes) %>% as.character(),
      gene_function = iatlas.data::switch_value(.data, "gene", "gene_function", all_genes) %>% as.character(),
      immune_checkpoint = iatlas.data::switch_value(.data, "gene", "immune_checkpoint", all_genes) %>% as.character(),
      io_landscape_name = iatlas.data::switch_value(.data, "gene", "io_landscape_name", all_genes) %>% as.character(),
      pathway = iatlas.data::switch_value(.data, "gene", "pathway", all_genes) %>% as.character(),
      references = iatlas.data::switch_value(.data, "gene", "references", all_genes) %>% as.character(),
      super_category = iatlas.data::switch_value(.data, "gene", "super_category", all_genes) %>% as.character(),
      therapy_type = iatlas.data::switch_value(.data, "gene", "therapy_type", all_genes) %>% as.character()
    ) %>%
    dplyr::anti_join(all_genes, by = "gene")
  all_genes <- all_genes_expr %>%
    dplyr::bind_rows(all_genes) %>%
    dplyr::as_tibble() %>%
    dplyr::rename_at("gene", ~("hgnc")) %>%
    dplyr::arrange(hgnc)
  all_genes <- all_genes %>%
    dplyr::left_join(
      feather::read_feather(apply_path("gene_ids.feather")),
      by = "hgnc"
    )
  cat(crayon::blue("Built all gene data."), fill = TRUE)

  # Clean up.
  rm(all_genes_expr)
  rm(io_targets)
  rm(immunomodulators)
  cat("Cleaned up.", fill = TRUE)
  gc()

  cat(crayon::magenta("Building gene_types data."), fill = TRUE)
  gene_types <- dplyr::tibble(
    name = c("immunomodulator", "io_target", "driver_mutation", "extra_cellular_network"),
    display = c("Immunomodulator", "IO Target", "Driver Mutation", "Extra Cellular Network")
  )
  cat(crayon::blue("Built gene_types data."), fill = TRUE)

  cat(crayon::magenta("Building gene_types table."), fill = TRUE)
  table_written <- gene_types %>% iatlas.data::write_table_ts("gene_types")
  cat(crayon::blue("Built gene_types table. (", nrow(gene_types), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building mutation_codes_to_gene_types data."), fill = TRUE)
  mutation_codes_to_gene_types <- iatlas.data::read_table("mutation_codes") %>%
    dplyr::rename_at("id", ~("mutation_code_id")) %>%
    tibble::add_column(type = "driver_mutation" %>% as.character()) %>%
    dplyr::left_join(iatlas.data::read_table("gene_types"), by = c("type" = "name")) %>%
    dplyr::rename_at("id", ~("type_id")) %>%
    dplyr::distinct(mutation_code_id, type_id)
  cat(crayon::blue("Built mutation_codes_to_gene_types data (", nrow(mutation_codes), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building mutation_codes_to_gene_types table."), fill = TRUE)
  table_written <- mutation_codes_to_gene_types %>% iatlas.data::write_table_ts("mutation_codes_to_gene_types")
  cat(crayon::blue("Built mutation_codes_to_gene_types table. (", nrow(mutation_codes_to_gene_types), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building gene_families data."), fill = TRUE)
  gene_families <- all_genes %>% iatlas.data::rebuild_gene_relational_data("gene_family", "name")
  cat(crayon::blue("Built gene_families data."), fill = TRUE)

  cat(crayon::magenta("Building gene_families table."), fill = TRUE)
  table_written <- gene_families %>% iatlas.data::write_table_ts("gene_families")
  cat(crayon::blue("Built gene_families table. (", nrow(gene_families), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building gene_functions data."), fill = TRUE)
  gene_functions <- all_genes %>% iatlas.data::rebuild_gene_relational_data("gene_function", "name")
  cat(crayon::blue("Built gene_functions data."), fill = TRUE)

  cat(crayon::magenta("Building gene_functions table."), fill = TRUE)
  table_written <- gene_functions %>% iatlas.data::write_table_ts("gene_functions")
  cat(crayon::blue("Built gene_functions table. (", nrow(gene_functions), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building immune_checkpoints data."), fill = TRUE)
  immune_checkpoints <- all_genes %>% iatlas.data::rebuild_gene_relational_data("immune_checkpoint", "name")
  cat(crayon::blue("Built immune_checkpoints data."), fill = TRUE)

  cat(crayon::magenta("Building immune_checkpoints table."), fill = TRUE)
  table_written <- immune_checkpoints %>% iatlas.data::write_table_ts("immune_checkpoints")
  cat(crayon::blue("Built immune_checkpoints table. (", nrow(immune_checkpoints), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building node_types data."), fill = TRUE)
  node_types <- all_genes %>% iatlas.data::rebuild_gene_relational_data("node_type", "name")
  cat(crayon::blue("Built node_types data."), fill = TRUE)

  cat(crayon::magenta("Building node_types table."), fill = TRUE)
  table_written <- node_types %>% iatlas.data::write_table_ts("node_types")
  cat(crayon::blue("Built node_types table. (", nrow(node_types), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Built pathways data."), fill = TRUE)
  pathways <- all_genes %>% iatlas.data::rebuild_gene_relational_data("pathway", "name")
  cat(crayon::blue("Built pathways data."), fill = TRUE)

  cat(crayon::magenta("Built pathways table."), fill = TRUE)
  table_written <- pathways %>% iatlas.data::write_table_ts("pathways")
  cat(crayon::blue("Built pathways table. (", nrow(pathways), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building super_categories data."), fill = TRUE)
  super_categories <- all_genes %>% iatlas.data::rebuild_gene_relational_data("super_category", "name")
  cat(crayon::blue("Built super_categories data."), fill = TRUE)

  cat(crayon::magenta("Building super_categories table."), fill = TRUE)
  table_written <- super_categories %>% iatlas.data::write_table_ts("super_categories")
  cat(crayon::blue("Built super_categories table. (", nrow(super_categories), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Built therapy_types data."), fill = TRUE)
  therapy_types <- all_genes %>% iatlas.data::rebuild_gene_relational_data("therapy_type", "name")
  cat(crayon::blue("Built therapy_types data."), fill = TRUE)

  cat(crayon::magenta("Built therapy_types table."), fill = TRUE)
  table_written <- therapy_types %>% iatlas.data::write_table_ts("therapy_types")
  cat(crayon::blue("Built therapy_types table. (", nrow(therapy_types), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building genes data."), fill = TRUE)
  cat(crayon::cyan("Adding gene_family ids."), fill = TRUE)
  genes <- all_genes %>%
    dplyr::left_join(iatlas.data::read_table("gene_families"), by = c("gene_family" = "name")) %>%
    dplyr::rename_at("id", ~("gene_family_id"))
  cat(crayon::cyan("Adding gene_function ids."), fill = TRUE)
  genes <- genes %>%
    dplyr::left_join(iatlas.data::read_table("gene_functions"), by = c("gene_function" = "name")) %>%
    dplyr::rename_at("id", ~("gene_function_id"))
  cat(crayon::cyan("Adding immune_checkpoint ids."), fill = TRUE)
  genes <- genes %>%
    dplyr::left_join(iatlas.data::read_table("immune_checkpoints"), by = c("immune_checkpoint" = "name")) %>%
    dplyr::rename_at("id", ~("immune_checkpoint_id"))
  cat(crayon::cyan("Adding node_type ids."), fill = TRUE)
  genes <- genes %>%
    dplyr::left_join(iatlas.data::read_table("node_types"), by = c("node_type" = "name")) %>%
    dplyr::rename_at("id", ~("node_type_id"))
  cat(crayon::cyan("Adding pathway ids."), fill = TRUE)
  genes <- genes %>%
    dplyr::left_join(iatlas.data::read_table("pathways"), by = c("pathway" = "name")) %>%
    dplyr::rename_at("id", ~("pathway_id"))
  cat(crayon::cyan("Adding super_category ids."), fill = TRUE)
  genes <- genes %>%
    dplyr::left_join(iatlas.data::read_table("super_categories"), by = c("super_category" = "name")) %>%
    dplyr::rename_at("id", ~("super_cat_id"))
  cat(crayon::cyan("Adding therapy_type ids."), fill = TRUE)
  genes <- genes %>%
    dplyr::left_join(iatlas.data::read_table("therapy_types"), by = c("therapy_type" = "name")) %>%
    dplyr::rename_at("id", ~("therapy_type_id")) %>%
    dplyr::distinct(entrez, hgnc, description, friendly_name, gene_family_id, gene_function_id, immune_checkpoint_id, io_landscape_name, pathway_id, references, super_cat_id, therapy_type_id)
  cat(crayon::blue("Built genes data."), fill = TRUE)

  cat(crayon::magenta("Building genes table."), fill = TRUE)
  table_written <- genes %>% iatlas.data::write_table_ts("genes")
  cat(crayon::blue("Built genes table. (", nrow(genes), "rows )"), fill = TRUE, sep = " ")

  # Clean up.
  rm(all_genes)
  rm(gene_families)
  rm(gene_functions)
  rm(immune_checkpoints)
  rm(pathways)
  rm(super_categories)
  rm(therapy_types)
  cat("Cleaned up.", fill = TRUE)
  gc()

  cat(crayon::magenta("Building genes_to_types data."), fill = TRUE)
  genes <- iatlas.data::read_table("genes") %>% dplyr::select(id, hgnc)
  gene_types <- iatlas.data::read_table("gene_types")

  # Collect the ids of the 3 gene_types.
  driver_mutation_id <- gene_types %>% dplyr::filter(name == "driver_mutation") %>% .[["id"]]
  immunomodulator_id <- gene_types %>% dplyr::filter(name == "immunomodulator") %>% .[["id"]]
  io_target_id <- gene_types %>% dplyr::filter(name == "io_target") %>% .[["id"]]
  ecn_id <- gene_types %>% dplyr::filter(name == "extra_cellular_network") %>% .[["id"]]

  driver_mutations <- driver_mutations %>% tibble::add_column(type_id = driver_mutation_id %>% as.integer)
  ecns <- ecns %>% dplyr::distinct(gene) %>% tibble::add_column(type_id = ecn_id %>% as.integer)
  immunomodulator_expr <- immunomodulator_expr %>% tibble::add_column(type_id = immunomodulator_id %>% as.integer)
  io_target_expr <- io_target_expr %>% tibble::add_column(type_id = io_target_id %>% as.integer)

  genes_to_types <- driver_mutations %>%
    dplyr::bind_rows(ecns, immunomodulator_expr, io_target_expr) %>%
    dplyr::inner_join(genes, by = c("gene" = "hgnc")) %>%
    dplyr::rename_at("id", ~("gene_id")) %>%
    dplyr::distinct(gene_id, type_id) %>%
    dplyr::arrange(gene_id, type_id)
  cat(crayon::blue("Build genes_to_types data."), fill = TRUE)

  cat(crayon::magenta("Building genes_to_types table."), fill = TRUE)
  table_written <- genes_to_types %>% iatlas.data::write_table_ts("genes_to_types")
  cat(crayon::blue("Built genes_to_types table. (", nrow(genes_to_types), "rows )"), fill = TRUE, sep = " ")

  cat("Cleaned up.", fill = TRUE)
  gc()
}
