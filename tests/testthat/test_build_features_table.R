(function() {
  library("testthat")
  library('feather')

  .GlobalEnv$pool <- NULL

  setup(source(paste0(rprojroot::find_root("DESCRIPTION"), "/.Rprofile.d/ENV=test.R")))

  test_that("create_db", {
    create_db("test", "reset")
    expect_equal("fun", "fun")
  })

  test_that("connect_db", {
    .GlobalEnv$pool <- connect_to_db()
    expect_equal("fun", "fun")
  })

  # build_references
  test_that("build_features_tables", {
    expect_equal(.GlobalEnv$DB_NAME, "iatlas_shiny_test")

    build_features_tables("../../feather_files/SQLite_data/features.feather")
  })

  teardown(pool::poolClose(.GlobalEnv$pool))
  teardown(rm(pool, pos = ".GlobalEnv"))

  # teardown(source(paste0(rprojroot::find_root("DESCRIPTION"), "/.Rprofile.d/ENV=dev.R")))
})()
