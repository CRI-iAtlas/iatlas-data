(function() {
  library("testthat")
  library('feather')

  pool <- null

  setup(source("../../.Rprofile.d/ENV=test.R"))

  test_that("create_db", {
    create_db("test", "reset")
  })

  test_that("connect_db", {
    pool <<- connect_to_db()
  })

    # build_references
  test_that("build_features_table", {
    expect_equal(.GlobalEnv$DB_NAME, "iatlas_shiny_test")
    # build_features_table("../../feather_files/SQLite_data/features.feather")
  })

  teardown(pool::poolClose(pool))

})()
