(function() {
  library("testthat")
  library('feather')
  source('./lib_test_data.R')

  test_that("get_dupes", {
    df <- dplyr::tibble(
        key       = c(1, 2, 1),
        value_01  = c(NA, 42, 2),
        value_02  = c(2, 42, NA)
    )
    expected <- dplyr::tibble(
        key       = c(1, 1),
        value_01  = c(NA, 2),
        value_02  = c(2, NA)
    )
    expect_equal(iatlas.data::get_dupes(df, c("key")), expected)

  })

  # resolve_df_dupes
  test_that("resolve_df_dupes returns an object with duplicates resolved.", {
    df <- dplyr::tibble(
        key = c(1, 2, 1),
        value_01 = c(NA, 42, 2),
        value_02 = c(2, 42, NA)
    )
    expected <- dplyr::tibble(
        key = c(1, 2),
        value_01 = c(2, 42),
        value_02 = c(2, 42)
    )
    expect_equal(resolve_df_dupes(df, c("key")), expected)
  })
  test_that("resolve_df_dupes fails when multiple values are passed.", {
    df <- dplyr::tibble(
        key = c(1, 2, 1),
        value_01 = c(3, 42, 2),
        value_02 = c(2, 42, NA)
    )
    expect_error(resolve_df_dupes(df, c("key")), "DIRTY DATA\\!")
  })

  # flatten_dupes
  test_that("flatten_dupes returns a single value when duplicates are passed.", {
    expect_equal(flatten_dupes(c(1, 1, 1)), 1)
    expect_equal(flatten_dupes(c(1, 1, NA)), 1)
    expect_equal(flatten_dupes(c(1)), 1)
    expect_equal(flatten_dupes(c(NA)), NA)
  })
  test_that("flatten_dupes fails when multiple values are passed.", {
    expect_error(flatten_dupes(c(1, 2, 1)), "DIRTY DATA\\!")
  })

})()
