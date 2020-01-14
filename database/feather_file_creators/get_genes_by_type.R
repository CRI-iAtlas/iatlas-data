source("../load_dependencies.R")

.GlobalEnv$load_dependencies()

rm(load_dependencies, pos = ".GlobalEnv")

# The database connection.
source("../connect_to_db.R", chdir = TRUE)

# Create a global variable to hold the pool DB connection.
.GlobalEnv$pool <- .GlobalEnv$connect_to_db()

cat(crayon::green("Created DB connection."), fill = TRUE)

get_genes_by_type <- function(gene_type) {
  current_pool <- pool::poolCheckout(.GlobalEnv$pool)

  genes <- current_pool %>%
    dplyr::tbl("genes") %>%
    dplyr::as_tibble() %>%
    dplyr::right_join(
      current_pool %>%
        dplyr::tbl("genes_to_types") %>%
        dplyr::as_tibble(),
      by = c("id" = "gene_id")
    ) %>%
    dplyr::left_join(
      current_pool %>%
        dplyr::tbl("gene_types") %>%
        dplyr::as_tibble() %>%
        dplyr::select(id, name) %>%
        dplyr::rename_at("name", ~("type")),
      by = c("type_id" = "id")
    ) %>%
    dplyr::filter(type == gene_type) %>%
    dplyr::left_join(
      current_pool %>%
        dplyr::tbl("gene_families") %>%
        dplyr::as_tibble() %>%
        dplyr::rename_at("name", ~("gene_family")),
      by = c("gene_family_id" = "id")
    ) %>%
    dplyr::left_join(
      current_pool %>%
        dplyr::tbl("gene_functions") %>%
        dplyr::as_tibble() %>%
        dplyr::rename_at("name", ~("gene_function")),
      by = c("gene_function_id" = "id")
    ) %>%
    dplyr::left_join(
      current_pool %>%
        dplyr::tbl("immune_checkpoints") %>%
        dplyr::as_tibble() %>%
        dplyr::rename_at("name", ~("immune_checkpoint")),
      by = c("immune_checkpoint_id" = "id")
    ) %>%
    dplyr::left_join(
      current_pool %>%
        dplyr::tbl("pathways") %>%
        dplyr::as_tibble() %>%
        dplyr::rename_at("name", ~("pathway")),
      by = c("pathway_id" = "id")
    ) %>%
    dplyr::left_join(
      current_pool %>%
        dplyr::tbl("super_categories") %>%
        dplyr::as_tibble() %>%
        dplyr::rename_at("name", ~("super_category")),
      by = c("super_cat_id" = "id")
    ) %>%
    dplyr::left_join(
      current_pool %>%
        dplyr::tbl("therapy_types") %>%
        dplyr::as_tibble() %>%
        dplyr::rename_at("name", ~("therapy_type")),
      by = c("therapy_type_id" = "id")
    ) %>%
    dplyr::distinct(entrez, hgnc, gene_family, gene_function, immune_checkpoint, pathway, super_category, therapy_type, display, references)

  pool::poolReturn(current_pool)

  gene_ids <- feather::read_feather("../../feather_files/gene_ids.feather") %>%
    dplyr::as_tibble()

  genes <- genes %>%
    dplyr::left_join(gene_ids, by = "hgnc") %>%
    tibble::add_column(entrez = NA %>% as.character, .before = "hgnc") %>%
    dplyr::mutate(entrez = ifelse(is.na(entrez.x), entrez.y, entrez.x)) %>%
    dplyr::select(-c(entrez.x, entrez.y))

  return(genes)
}

driver_mutation_genes <- "driver_mutation" %>%
  get_genes_by_type %>%
  feather::write_feather("../../feather_files/genes/driver_mutation_genes.feather")

immunomodulator_genes <- "immunomodulator" %>%
  get_genes_by_type %>%
  feather::write_feather("../../feather_files/genes/immunomodulator_genes.feather")

io_target_genes <- "io_target" %>%
  get_genes_by_type %>%
  feather::write_feather("../../feather_files/genes/io_target_genes.feather")

# Close the database connection.
pool::poolClose(.GlobalEnv$pool)
cat(crayon::green("Closed DB connection."), fill = TRUE)

### Clean up ###
# Data
rm(pool, pos = ".GlobalEnv")
rm(driver_mutation_genes)
rm(immunomodulator_genes)
rm(io_target_genes)

# Functions
rm(connect_to_db, pos = ".GlobalEnv")
rm(get_genes_by_type, pos = ".GlobalEnv")

cat("Cleaned up.", fill = TRUE)
gc()
