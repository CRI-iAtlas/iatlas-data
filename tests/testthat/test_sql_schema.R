(function() {
  library("testthat")
  library('feather')

  test_that("get_dependent_tables when none", {
    result <- get_dependent_tables("features_to_samples")
    expect_equal(present(result), FALSE)
  })

  test_that("get_dependent_tables when many with patients", {
    result <- get_dependent_tables("patients")
    expect_equal(present(result), TRUE)
    expect_gte(length(result), 5)
  })

})()