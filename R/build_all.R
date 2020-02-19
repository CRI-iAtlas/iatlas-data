build_all <- function() {
  cat(crayon::bgBlue(crayon::white(crayon::bold("*** Building DEV/PROD DB...\n"))))
  iatlas.data::build_iatlas_db()
  cat(crayon::bgBlue(crayon::white(crayon::bold("*** Building TEST DB...\n"))))
  iatlas.data::build_iatlas_db(env="test", feather_file_folder = "tests/test_data/feather_files/")
}