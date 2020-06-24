# This file is called "zzz" so that it will run last.
(function() {
  with_test_db_env({
    test_that("build_iatlas_db", {
      iatlas.data::build_iatlas_db(
        env = "test",
        script_path = "../scripts"
      )
      expect_true(table_exists("genes"))
    })

    purrr::map(names(sql_schema), function(table_name) {
      test_that(paste0(table_name, " exists"), {
        expect_true(table_exists(table_name))
      })
    })
  })
})()
