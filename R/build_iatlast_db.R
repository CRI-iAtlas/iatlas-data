#' build_iatlas_db
#'
#' Build the full iAtlas database from source feather=files
#'
#' @param env
#' @param reset "reset" or "create" or NULL
#' @param resume_at = NULL or step-name-string - will skip all steps until the specified step, which will be executed as well as all following steps
#' resume_at can also == "auto" and it will resume at the previous fail-point, or, if none, it will start at the top
#'
#' @param stop_at = NULL or step-name-string - will stop executing AFTER executing the specified step. Will not execute any more steps.
#' @return nothing
build_iatlas_db <- function(env = "dev", reset = "reset", show_gc_info = FALSE, resume_at = NULL, stop_at = NULL, feather_file_folder = "feather_files") {

  option_equal <- function (a, b) {present(a) && present(b) && a == b}
  if (option_equal(resume_at, "auto")) {resume_at = .GlobalEnv$resume_at;}
  if (present(.GlobalEnv$resume_at)) {rm(resume_at, pos = ".GlobalEnv")}
  running_is_on <- is.null(resume_at)
  stopped <- FALSE

  num_skippable_steps <- 12 # search this file and count for run_skippable_function calls
  skippable_step_count <- 1

  tictoc::tic(paste0("Time taken to build iAtlas DB"))

  run_skippable_function <- function(f, ...) {
    function_name <- as.character(substitute(f))
    if (option_equal(resume_at, function_name)) running_is_on <<- TRUE;
    if (running_is_on) {
      cat(crayon::green("\n--------------------------------------------------------------------------------"), fill = TRUE)
      cat(crayon::green(paste0("START: ", function_name, " (build_iatlas_db step ", skippable_step_count, "/", num_skippable_steps, ")")), fill = TRUE)
      skippable_step_count <<- skippable_step_count + 1

      tryCatch({
        .GlobalEnv$resume_at <- function_name
        f(...)
        gc()
      }, error = function(e) {
        cat(crayon::magenta(crayon::bold(paste0(function_name, " failed, but don't fret, you can resume from here:"))), fill = TRUE)

        cat(crayon::magenta(crayon::bold(paste0("OPTION 1: resume from last failure automatically: build_iatlas_db(..., resume_at = 'auto')"))), fill = TRUE)
        cat(crayon::magenta(crayon::bold(paste0("OPTION 2: resume exactly this step:               build_iatlas_db(..., resume_at = '", function_name, "')"))), fill = TRUE)
        running_is_on <<- FALSE
        stop(e)
      })
      cat(crayon::green(paste0("SUCCESS: ", function_name)), fill = TRUE)
    } else if (stopped) {
      cat(crayon::yellow(paste0("STOPPED. SKIPPING: '", function_name, "' (as requested by stop_at option)" )), fill = TRUE)
    } else {
      cat(crayon::yellow(paste0("SKIPPING: '", function_name, "' (as requested by resume_at options)" )), fill = TRUE)
    }
    if (option_equal(stop_at, function_name)) {
      cat(crayon::bold(crayon::yellow(paste0("STOPPING AFTER: '", function_name, "' (as requested by stop_at = '",function_name, "')"))), fill = TRUE)
      stopped <<- TRUE
      running_is_on <<- FALSE;
    }
  }

  # Show garbage collection info
  gcinfo(show_gc_info)

  # Reset the database so new data is not corrupted by any old data.
  run_skippable_function(create_db, env, reset)

  # Create a global variable to hold the pool DB connection.
  cat(crayon::green("OPEN: DB connection..."), fill = TRUE)
  .GlobalEnv$pool <- iatlas.data::connect_to_db()

  run_skippable_function(build_features_tables,       feather_file_folder)
  run_skippable_function(build_tags_tables,           feather_file_folder)
  run_skippable_function(build_genes_tables,          feather_file_folder)

  # before build-samples-tables ---------------------------------------------------

  # read genes table, rna-sequence-expression and raw samples ---------------------------------------------------
  genes <- iatlas.data::read_table("genes") %>% dplyr::as_tibble() %>% dplyr::select(id, hgnc)
  rna_seq_expr_matrix <- load_rna_seq_expr(feather_file_folder, genes)
  all_samples <- load_all_samples(feather_file_folder)

  run_skippable_function(build_patients_table, feather_file_folder, all_samples, rna_seq_expr_matrix)

  # read-back patients and add patient_id to samples ---------------------------------------------------
  cat(crayon::magenta("Add patient_id to samples data."), fill = TRUE)
  patients <- iatlas.data::read_table("patients") %>% dplyr::select(patient_id = id, sample = barcode)
  all_samples_with_patient_ids <- all_samples %>% dplyr::left_join(patients, by = "sample")
  cat(crayon::blue("Added patient_id to samples data."), fill = TRUE)

  run_skippable_function(build_samples_table, all_samples_with_patient_ids)

  # read-back sample db data ---------------------------------------------------
  cat(crayon::magenta("Read the samples table to get samples data with ids."), fill = TRUE)
  samples <- iatlas.data::read_table("samples") %>% dplyr::as_tibble()
  cat(crayon::blue("Done reading the samples table."), fill = TRUE, sep = " ")

  run_skippable_function(build_samples_to_tags_table,     all_samples_with_patient_ids, samples)
  run_skippable_function(build_features_to_samples_table, all_samples_with_patient_ids, samples)
  run_skippable_function(build_genes_to_samples_table,    all_samples_with_patient_ids, rna_seq_expr_matrix, genes, samples)

  run_skippable_function(build_slides_table,              feather_file_folder, patients)

  rm(samples)
  rm(patients)
  rm(all_samples)
  rm(rna_seq_expr_matrix)
  rm(genes)

  # after build-samples-tables ---------------------------------------------------
  run_skippable_function(build_driver_results_tables, feather_file_folder)
  run_skippable_function(build_nodes_tables,          feather_file_folder)

  # Close the database connection.
  cat(crayon::green("CLOSE: DB connection..."), fill = TRUE)
  pool::poolClose(.GlobalEnv$pool)
  rm(pool, pos = ".GlobalEnv")

  if (present(.GlobalEnv$resume_at)) {rm(resume_at, pos = ".GlobalEnv")}

  cat(crayon::bold(crayon::blue("\n================================================================================")), fill = TRUE)
  cat(crayon::bold(crayon::blue(paste0("SUCCESS! iAtlas DB created."))), fill = TRUE)
  tictoc::toc()

  # Don't show garbage collection details any longer.
  gcinfo(FALSE)
  invisible(NULL);
}
