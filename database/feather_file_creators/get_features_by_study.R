source("../../R/load_dependencies.R")

iatlas.data::load_dependencies()

rm(load_dependencies, pos = ".GlobalEnv")

# The database connection.
source("../../R/connect_to_db.R", chdir = TRUE)

# Create a global variable to hold the pool DB connection.
.GlobalEnv$pool <- iatlas.data::connect_to_db()

cat(crayon::green("Created DB connection."), fill = TRUE)

get_features_by_study <- function(study) {
  current_pool <- pool::poolCheckout(.GlobalEnv$pool)

  features <- current_pool %>%
    dplyr::tbl("features") %>%
    dplyr::right_join(
      current_pool %>%
        dplyr::tbl("features_to_samples"),
      by = c("id" = "feature_id")
    ) %>%
    dplyr::right_join(
      current_pool %>%
        dplyr::tbl("samples_to_tags") %>%
        dplyr::right_join(
          current_pool %>%
            dplyr::tbl("tags_to_tags") %>%
            dplyr::right_join(
              current_pool %>%
                dplyr::tbl("tags") %>%
                dplyr::select(id, name) %>%
                dplyr::rename_at("name", ~("study_name")),
              by = c("related_tag_id" = "id")
            ) %>%
            dplyr::filter(study_name == study),
          by = "tag_id"
        ),
      by = c("id" = "sample_id")
    ) %>%
    dplyr::left_join(
      current_pool %>%
        dplyr::tbl("classes") %>%
        dplyr::select(id, name) %>%
        dplyr::rename_at("name", ~("class")),
      by = c("class_id" = "id")
    ) %>%
    dplyr::left_join(
      current_pool %>%
        dplyr::tbl("method_tags") %>%
        dplyr::select(id, name) %>%
        dplyr::rename_at("name", ~("method_tag")),
      by = c("method_tag_id" = "id")
    ) %>%
    dplyr::distinct(class, display, method_tag, name, order, unit) %>%
    dplyr::as_tibble()

  pool::poolReturn(current_pool)

  return(features)
}

tcga_study_features <- "TCGA_Study" %>%
  get_features_by_study %>%
  feather::write_feather("../../feather_files/features/tcga_study_features.feather")

tcga_subtype_features <- "TCGA_Subtype" %>%
  get_features_by_study %>%
  feather::write_feather("../../feather_files/features/tcga_subtype_features.feather")

immune_subtype_features <- "Immune_Subtype" %>%
  get_features_by_study %>%
  feather::write_feather("../../feather_files/features/immune_subtype_features.feather")

# Close the database connection.
pool::poolClose(.GlobalEnv$pool)
cat(crayon::green("Closed DB connection."), fill = TRUE)

### Clean up ###
# Data
rm(pool, pos = ".GlobalEnv")
rm(tcga_study_features)
rm(tcga_subtype_features)
rm(immune_subtype_features)

# Functions
rm(connect_to_db, pos = ".GlobalEnv")
rm(get_features_by_study, pos = ".GlobalEnv")

cat("Cleaned up.", fill = TRUE)
gc()
