source("../load_dependencies.R")

.GlobalEnv$load_dependencies()

rm(load_dependencies, pos = ".GlobalEnv")

# The database connection.
source("../connect_to_db.R", chdir = TRUE)

# Create a global variable to hold the pool DB connection.
.GlobalEnv$pool <- .GlobalEnv$connect_to_db()

cat(crayon::green("Created DB connection."), fill = TRUE)

get_tags_by_study <- function(study) {
  current_pool <- pool::poolCheckout(.GlobalEnv$pool)

  tags <- current_pool %>%
    dplyr::tbl("tags") %>%
    dplyr::as_tibble() %>%
    dplyr::right_join(
      current_pool %>%
        dplyr::tbl("tags_to_tags") %>%
        dplyr::as_tibble(),
      by = c("id" = "tag_id")
    ) %>%
    dplyr::right_join(
      current_pool %>%
        dplyr::tbl("tags_to_tags") %>%
        dplyr::as_tibble() %>%
        dplyr::right_join(
          current_pool %>%
            dplyr::tbl("tags") %>%
            dplyr::as_tibble() %>%
            dplyr::select(id, name) %>%
            dplyr::rename_at("name", ~("related_tag_name")),
          by = c("related_tag_id" = "id")) %>%
        dplyr::filter(related_tag_name == study),
      by = c("id" = "tag_id")
    ) %>%
    dplyr::distinct(name, characteristics, display, color)

  pool::poolReturn(current_pool)

  return(tags)
}

tcga_study_tags <- "TCGA_Study" %>%
  get_tags_by_study %>%
  feather::write_feather("../../feather_files/tags/tcga_study_tags.feather")

tcga_subtype_tags <- "TCGA_Subtype" %>%
  get_tags_by_study %>%
  feather::write_feather("../../feather_files/tags/tcga_subtype_tags.feather")

immune_subtype_tags <- "Immune_Subtype" %>%
  get_tags_by_study %>%
  feather::write_feather("../../feather_files/tags/immune_subtype_tags.feather")

# Close the database connection.
pool::poolClose(.GlobalEnv$pool)
cat(crayon::green("Closed DB connection."), fill = TRUE)

### Clean up ###
# Data
rm(pool, pos = ".GlobalEnv")
rm(tcga_study_tags)
rm(tcga_subtype_tags)
rm(immune_subtype_tags)

# Functions
rm(connect_to_db, pos = ".GlobalEnv")
rm(get_tags_by_study, pos = ".GlobalEnv")

cat("Cleaned up.", fill = TRUE)
gc()
