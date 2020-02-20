(function() {
  library("testthat")
  library('feather')
  source('./lib_test_data.R')

  with_test_db_env({
    test_that("create_global_db_pool and release_global_db_pool", {
      expect_false(present(.GlobalEnv$pool))
      create_global_db_pool()
      expect_true(present(.GlobalEnv$pool))
      pool <- .GlobalEnv$pool
      create_global_db_pool()
      expect_identical(pool, .GlobalEnv$pool)

      release_global_db_pool()
      expect_false(present(.GlobalEnv$pool))
      release_global_db_pool()
      expect_false(present(.GlobalEnv$pool))
    })

    test_that("vivify_global_db_pool and release_global_db_pool", {
      expect_false(present(.GlobalEnv$pool))
      vivify_global_db_pool()
      expect_true(present(.GlobalEnv$pool))
      pool <- .GlobalEnv$pool
      vivify_global_db_pool()
      expect_identical(pool, .GlobalEnv$pool)

      release_global_db_pool()
    })
  })
})()


# create_global_db_pool <- function() {
#   if (!iatlas.data::present(.GlobalEnv$pool)) {
#     .GlobalEnv$pool <- iatlas.data::connect_to_db()
#   } else {
#     cat(crayon::yellow("WARNING-create_global_db_pool: global db pool already created\n"))
#     .GlobalEnv$pool
#   }
# }

# vivify_global_db_pool <- function() {
#   if (!iatlas.data::present(.GlobalEnv$pool)) create_global_db_pool()
#   else .GlobalEnv$pool
# }

# release_global_db_pool <- function() {
#   if (iatlas.data::present(.GlobalEnv$pool)) {
#     pool::poolClose(.GlobalEnv$pool)
#     rm(pool, pos = ".GlobalEnv")
#   } else {
#     cat(crayon::yellow("WARNING-release_global_db_pool: Nothing to do. Global db pool does not exist. \n"))
#   }
# }
