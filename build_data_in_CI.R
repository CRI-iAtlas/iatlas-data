DB_NAME <- Sys.getenv("DB_NAME", unset = "iatlas_dev")
DB_HOST <- Sys.getenv("DB_HOST", unset = "localhost")
DB_PORT <- Sys.getenv("DB_PORT", unset = "5432")
DB_USER <- Sys.getenv("DB_USER", unset = "postgres")
DB_PW <- Sys.getenv("DB_PW", unset = "docker")

source("database/load_dependencies.R")

.GlobalEnv$load_dependencies()

rm(load_dependencies, pos = ".GlobalEnv")

# Make the custom data functions available.
source("database/data_functions.R", chdir = TRUE)

# Make the custom database functions available.
source("database/database_functions.R", chdir = TRUE)

# The database connection.
source("database/connect_to_db.R", chdir = TRUE)

# Create a global variable to hold the pool DB connection.
.GlobalEnv$pool <- .GlobalEnv$connect_to_db()

cat(crayon::green("Created DB connection."), fill = TRUE)

source("database/build_features_tables.R", chdir = TRUE)

source("database/build_tags_tables.R", chdir = TRUE)

source("database/build_gene_tables.R", chdir = TRUE)

source("database/build_samples_tables.R", chdir = TRUE)

source("database/build_results_tables.R", chdir = TRUE)

source("database/build_nodes_tables.R", chdir = TRUE)

# Close the database connection.
pool::poolClose(.GlobalEnv$pool)

cat(crayon::green("Closed DB connection."), fill = TRUE)

### Clean up ###
# Data
rm(pool, pos = ".GlobalEnv")

# Functions
rm(connect_to_db, pos = ".GlobalEnv")
rm(delete_rows, pos = ".GlobalEnv")
rm(filter_na, pos = ".GlobalEnv")
rm(is_df_empty, pos = ".GlobalEnv")
rm(link_to_references, pos = ".GlobalEnv")
rm(load_feather_data, pos = ".GlobalEnv")
rm(read_table, pos = ".GlobalEnv")
rm(rebuild_gene_relational_data, pos = ".GlobalEnv")
rm(switch_value, pos = ".GlobalEnv")
rm(write_table_ts, pos = ".GlobalEnv")

cat("Cleaned up.", fill = TRUE)
gc()