route_logs_to_file <- function() {
  logging::basicConfig()
  logging::addHandler(logging::writeToFile, file="~/iatlas.data.log")
}

log_info <- function(...) {
  logging::loginfo(paste0(...))
}