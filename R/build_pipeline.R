build_pipeline <- function(step_function_names, resume_at = NULL, stop_at = NULL, finally = NULL) {

  on.exit(finally)

  option_equal <- function (a, b) {iatlas.data::present(a) && iatlas.data::present(b) && a == b}

  clear_globals <- function() {
    if (iatlas.data::present(.GlobalEnv$pipeline_stack_trace)) {rm(pipeline_stack_trace, pos = ".GlobalEnv")}
    if (iatlas.data::present(.GlobalEnv$resume)) {rm(resume, pos = ".GlobalEnv")}
  }
  clear_globals()

  running_is_on <- is.null(resume_at)
  stopped <- FALSE

  num_skippable_steps <- length(step_function_names)
  skippable_step_count <- 1

  tictoc::tic(paste0("Time taken to run pipeline"))

  run_skippable_function <- function(function_name, ...) {
    f <- match.fun(function_name)
    on.exit(skippable_step_count <<- skippable_step_count + 1)
    if (option_equal(resume_at, function_name)) running_is_on <<- TRUE;
    if (running_is_on) {
      cat(crayon::green("\n--------------------------------------------------------------------------------"), fill = TRUE)
      cat(crayon::green(paste0("START: ", function_name, " (pipeline step ", skippable_step_count, "/", num_skippable_steps, ")")), fill = TRUE)

      withCallingHandlers({
        .GlobalEnv$resume_at <- function_name
        f(...)
        gc()
      }, error = function(e) {
        .GlobalEnv$pipeline_stack_trace <- sys.calls()
        .GlobalEnv$resume <- function (resume_at = function_name) {
          build_pipeline(step_function_names, resume_at = resume_at, stop_at = stop_at)
        }
        cat(crayon::red(crayon::bold(paste0(function_name, " failed, but don't fret, you can resume from here:"))), fill = TRUE)

        cat(crayon::magenta("OPTION: To resume from the last failure automatically:", crayon::bold(paste0("resume()"))), fill = TRUE)
        cat(paste0("NOTEs:\n  * If you change code, you can run ", crayon::bold("source('./.RProfile')")," and then use one of the resume-options above.\n  * The error's stack trace is available at: ", crayon::bold("pipeline_stack_trace")), fill = TRUE)
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

  for (stop_function_name in step_function_names) {
    run_skippable_function(stop_function_name)
  }

  clear_globals()

  cat(crayon::bold(crayon::blue("\n================================================================================")), fill = TRUE)
  cat(crayon::bold(crayon::blue(paste0("SUCCESS!"))), fill = TRUE)
  tictoc::toc()
}