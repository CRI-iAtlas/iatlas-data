build_all <- function() {
  cat(crayon::bgBlue(crayon::white(crayon::bold("*** Building 'iatlas_test' database ***\n"))))
  iatlas.data::build_iatlas_db(env = "test", max_rows = 100)
  cat(crayon::bgBlue(crayon::white(crayon::bold("*** Building 'iatlas_dev' database ***\n"))))
  iatlas.data::build_iatlas_db()
}
