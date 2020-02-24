# This file is called "zzz" so that it will run last.
(function() {
  library("testthat")
  library('feather')
  source('./lib_test_data.R')

  with_test_db_env({
    test_that("build_iatlas_db", {
      iatlas.data::build_iatlas_db(env = "test", feather_file_folder = get_test_data_path("feather_files"), script_path = "../scripts")
      expect_true(table_exists("genes"))
    })

    purrr::map(names(sql_schema), function(table_name) {
      test_that(paste0(table_name, " exists"), {
        expect_true(table_exists(table_name))
      })
    })
  })
})()
