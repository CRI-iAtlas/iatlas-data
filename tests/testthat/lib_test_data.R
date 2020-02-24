test_data_folder <- "../test_data"

copyEnv <- function(from, to, names = ls(from, all.names = TRUE)) {
  mapply(
    assign,
    names,
    mget(names, from),
    list(to),
    SIMPLIFY = FALSE,
    USE.NAMES = FALSE
  )
  invisible(NULL)
}

get_test_data_path <- function (sub_path) paste0(test_data_folder, "/", sub_path)

read_test_feather <- function (sub_path) read_feather(get_test_data_path(sub_path))
read_test_csv <- function (sub_path) dplyr::as_tibble(read.csv(get_test_data_path(sub_path), header = TRUE))
