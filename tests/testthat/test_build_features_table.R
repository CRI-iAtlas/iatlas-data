(function() {
  library("testthat")
  library('feather')

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

  .GlobalEnv$pool <- NULL

  backup_env <- new.env()
  copyEnv(.GlobalEnv, backup_env)

  .GlobalEnv$DB_NAME <- Sys.getenv("DB_NAME", unset = "iatlas_shiny_test")
  .GlobalEnv$DB_HOST <- Sys.getenv("DB_HOST", unset = "localhost")
  .GlobalEnv$DB_PORT <- Sys.getenv("DB_PORT", unset = "5432")
  .GlobalEnv$DB_USER <- Sys.getenv("DB_USER", unset = "postgres")
  .GlobalEnv$DB_PW <- Sys.getenv("DB_PW", unset = "docker")

  test_that("create_db", {
    iatlas.data::create_db("test", "reset")
    expect_equal("fun", "fun")
  })

  test_that("connect_db", {
    cat(crayon::bold(paste0("connect to db: ", .GlobalEnv$DB_NAME)), fill=)
    .GlobalEnv$pool <- connect_to_db()
    expect_equal(.GlobalEnv$DB_NAME, "iatlas_shiny_test")
  })

  test_that("build_features_tables", {
    iatlas.data::build_features_tables("../../feather_files/SQLite_data/features.feather")
    expect_equal("todo","todo")
  })

  test_that("build_tags_tables", {
    iatlas.data::build_tags_tables("../../feather_files/SQLite_data/groups.feather")
    expect_equal("todo","todo")
  })

  test_that("build_gene_tables", {
    iatlas.data::build_gene_tables("../../feather_files")
    expect_equal("todo","todo")
  })

  teardown(pool::poolClose(.GlobalEnv$pool))
  teardown(rm(pool, pos = ".GlobalEnv"))

  teardown(copyEnv(backup_env, .GlobalEnv))
})()
