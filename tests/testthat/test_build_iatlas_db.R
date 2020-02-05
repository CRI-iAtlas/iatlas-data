(function() {
  library("testthat")
  library('feather')
  source('./lib_test_data.R')

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

  feather_file_folder <- get_test_data_path("feather_files")

  test_that("create_db", {
    iatlas.data::create_db("test", "reset")
    expect_equal("fun", "fun")
  })

  test_that("connect_db", {
    cat(crayon::bold(paste0("connect to db: ", .GlobalEnv$DB_NAME)), fill=)
    .GlobalEnv$pool <- connect_to_db()
    expect_equal(.GlobalEnv$DB_NAME, "iatlas_shiny_test")
  })

  test_that("build_features_tables V2", {
    iatlas.data::build_features_tables(feather_file_folder)
    expect_equal("todo","todo")
  })

  test_that("build_tags_tables", {
    iatlas.data::build_tags_tables(feather_file_folder)
    expect_equal("todo","todo")
  })

  # test_that("build_genes_tables", {
  #   iatlas.data::build_genes_tables(feather_file_folder)
  #   expect_equal("todo","todo")
  # })

  # all_samples <- NULL
  # get_all_samples <- function() {all_samples}

  # test_that("get_all_samples", {
  #   all_samples <<- load_all_samples(feather_file_folder)
  #   expect_equal("todo","todo")
  # })

  # test_that("build_genes_tables", {
  #   iatlas.data::build_samples_table(feather_file_folder, get_all_samples)
  #   expect_equal("todo","todo")
  # })

  # samples <- NULL

  # test_that("load-back samples", {
  #   samples <<- iatlas.data::read_table("samples") %>% dplyr::as_tibble()
  #   expect_equal("todo","todo")
  # })

  # test_that("build_samples_to_tags_table", {
  #   iatlas.data::build_samples_to_tags_table(feather_file_folder, get_all_samples, samples)
  #   expect_equal("todo","todo")
  # })
  # test_that("build_samples_to_features_table", {
  #   iatlas.data::build_samples_to_features_table(feather_file_folder, get_all_samples, samples)
  #   expect_equal("todo","todo")
  # })

  all_samples <- NULL
  samples <- NULL

  teardown(pool::poolClose(.GlobalEnv$pool))
  teardown(rm(pool, pos = ".GlobalEnv"))
  teardown(copyEnv(backup_env, .GlobalEnv))
})()
