test_data_folder <- "../test_data"

copyEnv <- function(from, to, names=ls(from, all.names=TRUE)) {
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

with_test_db_env <- function(tests) {
  backup_env <- new.env()
  copyEnv(.GlobalEnv, backup_env)
  on.exit(teardown(copyEnv(backup_env, .GlobalEnv)))

  .GlobalEnv$DB_NAME <- "iatlas_shiny_test"
  .GlobalEnv$DB_HOST <- "localhost"
  .GlobalEnv$DB_PORT <- "5432"
  .GlobalEnv$DB_USER <- "postgres"
  .GlobalEnv$DB_PW   <- "docker"

  tests
}

get_test_data_path <- function (sub_path) paste0(test_data_folder, "/", sub_path)

read_test_feather <- function (sub_path) read_feather(get_test_data_path(sub_path))
read_test_csv <- function (sub_path) dplyr::as_tibble(read.csv(get_test_data_path(sub_path), header = TRUE))
