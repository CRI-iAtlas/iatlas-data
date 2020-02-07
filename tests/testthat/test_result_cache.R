(function() {
  library("testthat")
  source('./lib_test_data.R')
  test_that("reset_results_cache", {
    reset_results_cache()
    empty <- new.env()
    expect_equal(get_result_cache(), empty)
  })

  test_that("full results_cache test", {
    reset_results_cache()
    a <- new.env()
    a$foo = 123

    result_cached("foo", 123)
    expect_equal(get_result_cache(), a)

    reset_results_cache()
    empty <- new.env()
    expect_equal(get_result_cache(), empty)
  })

  test_that("expression is not executed if already cached", {
    reset_results_cache()
    result_cached("count", 1)
    result_cached("count", stop("this would crash, but it never gets executed"))

    expect_equal(get_result_cache()$count, 1)
  })

})()
