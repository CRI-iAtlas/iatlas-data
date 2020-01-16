source("../load_dependencies.R")

.GlobalEnv$load_dependencies()

rm(load_dependencies, pos = ".GlobalEnv")

# The database connection.
source("../connect_to_db.R", chdir = TRUE)

# Create a global variable to hold the pool DB connection.
.GlobalEnv$pool <- .GlobalEnv$connect_to_db()

cat(crayon::green("Created DB connection."), fill = TRUE)

get_samples_by_study <- function(study) {
  current_pool <- pool::poolCheckout(.GlobalEnv$pool)

  samples <- current_pool %>%
    dplyr::tbl("samples") %>%
    dplyr::as_tibble() %>%
    dplyr::right_join(
      current_pool %>%
        dplyr::tbl("samples_to_tags") %>%
        dplyr::as_tibble(),
      by = c("id" = "sample_id")
    ) %>%
    dplyr::left_join(
      current_pool %>%
        dplyr::tbl("tags") %>%
        dplyr::as_tibble() %>%
        dplyr::select(id, name) %>%
        dplyr::rename_at("name", ~("tag_name")),
      by = c("tag_id" = "id")
    ) %>%
    dplyr::right_join(
      current_pool %>%
        dplyr::tbl("tags_to_tags") %>%
        dplyr::as_tibble() %>%
        dplyr::right_join(
          current_pool %>%
            dplyr::tbl("tags") %>%
            dplyr::as_tibble() %>%
            dplyr::select(id, name),
          by = c("related_tag_id" = "id")) %>%
        dplyr::filter(name == study),
      by = "tag_id"
    ) %>%
    dplyr::select(sample_id, tissue_id)

  pool::poolReturn(current_pool)

  return(samples)
}

tcga_study_samples <- "TCGA_Study" %>%
  get_samples_by_study %>%
  feather::write_feather("../../feather_files/samples/tcga_study_samples.feather")

tcga_subtype_samples <- "TCGA_Subtype" %>%
  get_samples_by_study %>%
  feather::write_feather("../../feather_files/samples/tcga_subtype_samples.feather")

immune_subtype_samples <- "Immune_Subtype" %>%
  get_samples_by_study %>%
  feather::write_feather("../../feather_files/samples/immune_subtype_samples.feather")

# Close the database connection.
pool::poolClose(.GlobalEnv$pool)
cat(crayon::green("Closed DB connection."), fill = TRUE)

### Clean up ###
# Data
rm(pool, pos = ".GlobalEnv")
rm(tcga_study_samples)
rm(tcga_subtype_samples)
rm(immune_subtype_samples)

# Functions
rm(connect_to_db, pos = ".GlobalEnv")
rm(get_samples_by_study, pos = ".GlobalEnv")

cat("Cleaned up.", fill = TRUE)
gc()
