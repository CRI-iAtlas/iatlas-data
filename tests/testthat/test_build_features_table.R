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

  exists <- function (file) {
    paste0(
      file,
      " exists: ",
      file.exists(file)
    )
  }

  # system("find ../../ > /Users/shanebdavis/temp/iatlas.data.cover.files.txt")

  # stop(crayon::yellow(paste(
  #   "\n====================================================================",
  #   exists("../test_data"),
  #   exists("../test_data/integrations"),
  #   exists("../test_data/integrations/features.feather"),
  #   # "getwd: ",
  #   # getwd(),
  #   # "find_root: ",
  #   # rprojroot::find_root("DESCRIPTION"),
  #   # exists("../../iatlas.data-feather_files"),
  #   # exists("../feather_files"),
  #   "====================================================================",
  #   sep = "\n"
  # )))


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
    iatlas.data::build_features_tables("../test_data/integrations/features.feather")
    expect_equal("todo","todo")
  })

  test_that("build_tags_tables", {
    iatlas.data::build_tags_tables("../test_data/integrations/groups.feather")
    expect_equal("todo","todo")
  })

  # test_that("build_gene_tables", {
  #   iatlas.data::build_gene_tables("../../feather_files")
  #   expect_equal("todo","todo")
  # })

  teardown(pool::poolClose(.GlobalEnv$pool))
  teardown(rm(pool, pos = ".GlobalEnv"))

  teardown(copyEnv(backup_env, .GlobalEnv))
})()
