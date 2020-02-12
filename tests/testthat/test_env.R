(function() {
  library("testthat")
  library('feather')
  source('./lib_test_data.R')

  test_that("DB_NAME is iatlas_test", {
    expect_equal(.GlobalEnv$DB_NAME, "iatlas_test")
  })

})()
