source("../load_dependencies.R")

.GlobalEnv$load_dependencies()

rm(load_dependencies, pos = ".GlobalEnv")

# The database connection.
source("../connect_to_db.R", chdir = TRUE)

# Create a global variable to hold the pool DB connection.
.GlobalEnv$pool <- .GlobalEnv$connect_to_db()

cat(crayon::green("Created DB connection."), fill = TRUE)

get_driver_results <- function() {
  current_pool <- pool::poolCheckout(.GlobalEnv$pool)

  driver_results <- current_pool %>%
    dplyr::tbl("driver_results") %>%
    dplyr::as_tibble() %>%
    dplyr::left_join(
        current_pool %>%
        dplyr::tbl("features") %>%
        dplyr::as_tibble() %>%
        dplyr::select(id, name) %>%
        dplyr::rename_at("name", ~("feature")),
      by = c("feature_id" = "id")
    ) %>%
    dplyr::left_join(
        current_pool %>%
        dplyr::tbl("genes") %>%
        dplyr::as_tibble() %>%
        dplyr::select(id, hgnc),
      by = c("gene_id" = "id")
    ) %>%
    dplyr::left_join(
        current_pool %>%
        dplyr::tbl("tags") %>%
        dplyr::as_tibble() %>%
        dplyr::select(id, name) %>%
        dplyr::rename_at("name", ~("tag")),
      by = c("tag_id" = "id")
    ) %>%
    dplyr::distinct(feature, hgnc, tag, p_value, fold_change, log10_p_value, log10_fold_change, n_wt, n_mut)

  pool::poolReturn(current_pool)

  return(driver_results)
}

driver_results <- get_driver_results() %>%
  feather::write_feather("../../feather_files/driver_results/driver_results.feather")

# Close the database connection.
pool::poolClose(.GlobalEnv$pool)
cat(crayon::green("Closed DB connection."), fill = TRUE)

### Clean up ###
# Data
rm(pool, pos = ".GlobalEnv")
# rm(driver_results)

# Functions
rm(get_driver_results, pos = ".GlobalEnv")

cat("Cleaned up.", fill = TRUE)
gc()
