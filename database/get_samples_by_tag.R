source("database/load_dependencies.R")

.GlobalEnv$load_dependencies()

rm(load_dependencies, pos = ".GlobalEnv")

# The database connection.
source("database/connect_to_db.R", chdir = TRUE)

# Create a global variable to hold the pool DB connection.
.GlobalEnv$pool <- .GlobalEnv$connect_to_db()

cat(crayon::green("Created DB connection."), fill = TRUE)

get_samples_by_tag <- function(tag) {
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
        dplyr::as_tibble(),
      by = c("tag_id" = "id")
    ) %>%
    dplyr::rename_at("name", ~("tag_name")) %>%
    dplyr::right_join(
      current_pool %>%
        dplyr::tbl("tags_to_tags") %>%
        dplyr::as_tibble() %>%
        dplyr::right_join(
          current_pool %>%
            dplyr::tbl("tags") %>%
            dplyr::as_tibble(),
          by = c("related_tag_id" = "id")) %>%
        dplyr::filter(name == tag),
      by = "tag_id"
    ) %>%
    dplyr::select(-c(id, gender, race, ethnicity, tag_id, tag_name, related_tag_id, name, characteristics.x, display.x, color.x, characteristics.y, display.y, color.y))

  pool::poolReturn(current_pool)

  return(samples)
}

tcga_study_samples <- "TCGA_Study" %>%
  get_samples_by_tag %>%
  feather::write_feather("feather_files/samples/tcga_study_samples.feather")

tcga_subtype_samples <- "TCGA_Subtype" %>%
  get_samples_by_tag %>%
  feather::write_feather("feather_files/samples/tcga_subtype_samples.feather")

immune_subtype_samples <- "Immune_Subtype" %>%
  get_samples_by_tag %>%
  feather::write_feather("feather_files/samples/immune_subtype_samples.feather")

# Close the database connection.
pool::poolClose(.GlobalEnv$pool)
cat(crayon::green("Closed DB connection."), fill = TRUE)

### Clean up ###
# Data
rm(pool, pos = ".GlobalEnv")
# rm(tcga_samples)

# Functions
rm(get_samples_by_tag, pos = ".GlobalEnv")

cat("Cleaned up.", fill = TRUE)
gc()
