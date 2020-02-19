get_result_cache <- function () {
  if (!iatlas.data:::present(.GlobalEnv$result_cache))
    .GlobalEnv$result_cache <- new.env()
  .GlobalEnv$result_cache
}

result_cached <- function (key, value) {
  result_cache <- get_result_cache()
  if (iatlas.data:::present(result_cache[[key]])) result_cache[[key]]
  else result_cache[[key]] <- value
}

reset_results_cache <- function () {
  if (iatlas.data:::present(.GlobalEnv$result_cache)) {
    rm(result_cache, pos = .GlobalEnv)
  }
  gc()
}

reset_results_cache()
