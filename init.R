source("R/load_dependencies.R")

.GlobalEnv$load_dependencies()

rm(load_dependencies, pos = ".GlobalEnv")

#' build_iatlas_db
#'
#' Build the full iAtlas database from source feather-files
#'
#' @param env
#' @param reset "reset" or "create" or NULL
#' @param resume_at = NULL or step-name-string - will skip all steps until the specified step, which will be executed as well as all following steps
#' resume_at can also == "auto" and it will resume at the previous fail-point, or, if none, it will start at the top
#'
#' @param stop_after = NULL or step-name-string - will stop executing AFTER executing the specified step. Will not execute any more steps.
#' @return nothing
build_iatlas_db <- function(env = "dev", reset = NULL, show_gc_info = FALSE, resume_at = NULL, stop_after = NULL) {

  present <- function (a) {!is.na(a) && !is.null(a)}
  option_equal <- function (a, b) {present(a) && present(b) && a == b}
  if (option_equal(resume_at, "auto")) {resume_at = .GlobalEnv$resume_at;}
  if (present(.GlobalEnv$resume_at)) {rm(resume_at, pos = ".GlobalEnv")}
  running_is_on <- is.null(resume_at)

  run_build_script <- function(script_name, ...) {
    if (option_equal(resume_at, script_name)) running_is_on <<- TRUE;
    if (running_is_on) {
      cat(crayon::green(paste0("before build step: ", script_name)), fill = TRUE)

      tryCatch({
        source(paste0("R/",script_name,".R"))$value(...)
      }, error = function(e) {
        .GlobalEnv$resume_at <- script_name
        cat(crayon::magenta(crayon::bold(paste0(script_name, " failed, but don't fret, you can resume from here:"))), fill = TRUE)

        cat(crayon::magenta(crayon::bold(paste0("OPTION 1: resume from last failure automatically: build_iatlas_db(..., resume_at = 'auto')"))), fill = TRUE)
        cat(crayon::magenta(crayon::bold(paste0("OPTION 2: resume exactly this step:               build_iatlas_db(..., resume_at = '", script_name, "')"))), fill = TRUE)
        running_is_on <<- FALSE
        stop(e)
      })
      cat(crayon::green(paste0("after build step: ", script_name)), fill = TRUE)
    } else {
      cat(crayon::green(paste0("Skipping '", script_name, "' (as requested by resume_at or stop_after options)" )), fill = TRUE)
    }
    if (option_equal(stop_after, script_name)) {
      cat(crayon::bold(crayon::green(paste0("Stopping after: '", script_name, "' (as requested by stop_after = '",script_name, "')"))), fill = TRUE)
      running_is_on <<- FALSE;
    }
  }

  # Make the custom data functions available.
  source("R/data_functions.R", chdir = TRUE)

  # Make the custom database functions available.
  source("R/database_functions.R", chdir = TRUE)

  # The database connection.
  source("R/connect_to_db.R", chdir = TRUE)

  # Reset the database so new data is not corrupted by any old data.
  run_build_script("create_db", env, reset)

  # Show garbage collection info
  gcinfo(show_gc_info)

  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- .GlobalEnv$connect_to_db()

  cat(crayon::green("Created DB connection."), fill = TRUE)

  run_build_script("build_features_tables", "feather_files/SQLite_data/features.feather")
  run_build_script("build_tags_tables", "feather_files/SQLite_data/groups.feather")
  run_build_script("build_gene_tables", "feather_files")
  run_build_script("build_samples_tables", "feather_files")

  source("database/build_driver_results_tables.R", chdir = TRUE)

  run_build_script("build_nodes_tables", "feather_files")

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)

  cat(crayon::green("Closed DB connection."), fill = TRUE)

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")

  # Functions
  rm(build_features_tables, pos = ".GlobalEnv")
  rm(build_genes_tables, pos = ".GlobalEnv")
  rm(build_references, pos = ".GlobalEnv")
  rm(build_tags_tables, pos = ".GlobalEnv")
  rm(connect_to_db, pos = ".GlobalEnv")
  rm(delete_rows, pos = ".GlobalEnv")
  rm(driver_results_label_to_hgnc, pos = ".GlobalEnv")
  rm(filter_na, pos = ".GlobalEnv")
  rm(get_mutation_code, pos = ".GlobalEnv")
  rm(get_tag_column_names, pos = ".GlobalEnv")
  rm(get_unique_valid_values, pos = ".GlobalEnv")
  rm(is_df_empty, pos = ".GlobalEnv")
  rm(link_to_references, pos = ".GlobalEnv")
  rm(load_feather_data, pos = ".GlobalEnv")
  rm(print_dupe_info, pos = ".GlobalEnv")
  rm(read_table, pos = ".GlobalEnv")
  rm(rebuild_gene_relational_data, pos = ".GlobalEnv")
  rm(switch_value, pos = ".GlobalEnv")
  rm(trim_hgnc, pos = ".GlobalEnv")
  rm(validate_dupes, pos = ".GlobalEnv")
  rm(write_table_ts, pos = ".GlobalEnv")
  if (present(.GlobalEnv$resume_at)) {rm(resume_at, pos = ".GlobalEnv")}

  cat("Cleaned up.", fill = TRUE)
  gc()

  # Don't show garbage collection details any longer.
  gcinfo(FALSE)
  return(NA);
}
