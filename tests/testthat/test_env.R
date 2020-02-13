(function() {
  library("testthat")
  library('feather')
  source('./lib_test_data.R')

  with_test_db_env({
    test_that("DB_NAME is iatlas_test", {
      expect_equal(.GlobalEnv$DB_NAME, "iatlas_test")
    })
  })

})()
