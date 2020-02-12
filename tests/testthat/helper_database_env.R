with_test_db_env <- function(expr) {
  load_config('test')
  cat(crayon::yellow("with_test_db_env",.GlobalEnv$DB_NAME,"\n"))
  on.exit(load_config('dev'))
  expr
}