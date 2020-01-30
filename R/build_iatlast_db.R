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
build_iatlas_db <- function(env = "dev", reset = NULL, show_gc_info = FALSE, resume_at = NULL, stop_at = NULL, feather_file_folder = "feather_files") {

  present <- function (a) {!is.na(a) && !is.null(a)}
  option_equal <- function (a, b) {present(a) && present(b) && a == b}
  if (option_equal(resume_at, "auto")) {resume_at = .GlobalEnv$resume_at;}
  if (present(.GlobalEnv$resume_at)) {rm(resume_at, pos = ".GlobalEnv")}
  running_is_on <- is.null(resume_at)
  stopped <- FALSE

  tictoc::tic(paste0("Time taken to build iAtlas DB"))

  run_skippable_function <- function(f, ...) {
    function_name <- as.character(substitute(f))
    if (option_equal(resume_at, function_name)) running_is_on <<- TRUE;
    if (running_is_on) {
      cat(crayon::green("\n--------------------------------------------------------------------------------"), fill = TRUE)
      cat(crayon::green(paste0("START: ", function_name)), fill = TRUE)

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
  cat(crayon::green("CREATE: DB connection..."), fill = TRUE)
  .GlobalEnv$pool <- iatlas.data::connect_to_db()

  run_skippable_function(build_features_tables,       feather_file_folder)
  run_skippable_function(build_tags_tables,           feather_file_folder)
  run_skippable_function(build_genes_tables,          feather_file_folder)

  all_samples <- NULL
  get_all_samples <- function () {
    if (is.null(all_samples)) {
      all_samples <<- load_all_samples(feather_file_folder)
    }
    all_samples
  }
  all_samples <- get_all_samples()

  run_skippable_function(build_samples_table,         feather_file_folder, get_all_samples)

  samples <- iatlas.data::read_table("samples") %>% dplyr::as_tibble()

  run_skippable_function(build_samples_to_tags_table,     feather_file_folder, get_all_samples, samples)
  run_skippable_function(build_samples_to_features_table, feather_file_folder, get_all_samples, samples)

  all_samples <- NULL

  # run_skippable_function(build_samples_tables,        feather_file_folder)
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
