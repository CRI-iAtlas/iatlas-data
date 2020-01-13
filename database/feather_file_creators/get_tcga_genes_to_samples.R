source("../load_dependencies.R")

.GlobalEnv$load_dependencies()

rm(load_dependencies, pos = ".GlobalEnv")

# The database connection.
source("../connect_to_db.R", chdir = TRUE)

# Create a global variable to hold the pool DB connection.
.GlobalEnv$pool <- .GlobalEnv$connect_to_db()

cat(crayon::green("Created DB connection."), fill = TRUE)

get_tcga_genes_to_samples <- function() {
  current_pool <- pool::poolCheckout(.GlobalEnv$pool)

  genes_to_samples <- current_pool %>%
    dplyr::tbl("genes_to_samples") %>%
    dplyr::as_tibble() %>%
    dplyr::left_join(
      current_pool %>%
        dplyr::tbl("genes") %>%
        dplyr::as_tibble() %>%
        dplyr::select(id, hgnc),
      by = c("gene_id" = "id")
    ) %>%
    dplyr::left_join(
      current_pool %>%
        dplyr::tbl("samples") %>%
        dplyr::as_tibble() %>%
        dplyr::select(id, sample_id) %>%
        dplyr::rename_at("sample_id", ~("sample")),
      by = c("sample_id" = "id")
    ) %>%
    dplyr::distinct(hgnc, sample, rna_seq_expr, status)

  pool::poolReturn(current_pool)

  return(genes_to_samples)
}

tcga_genes_to_samples <- get_tcga_genes_to_samples() %>%
  feather::write_feather("../../feather_files/relationships/genes_to_samples/tcga_genes_to_samples.feather")

# Close the database connection.
pool::poolClose(.GlobalEnv$pool)
cat(crayon::green("Closed DB connection."), fill = TRUE)

### Clean up ###
# Data
rm(pool, pos = ".GlobalEnv")
rm(tcga_genes_to_samples)

# Functions
rm(get_tcga_genes_to_samples, pos = ".GlobalEnv")

cat("Cleaned up.", fill = TRUE)
gc()
