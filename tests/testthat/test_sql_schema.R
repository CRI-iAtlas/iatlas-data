(function() {
  library("testthat")
  library('feather')

  test_that("get_dependent_tables when none", {
    result <- get_dependent_tables("patients_to_slides")
    expect_equal(present(result), FALSE)
  })

  test_that("get_dependent_tables when many with patients", {
    result <- get_dependent_tables("patients")
    expect_equal(present(result), TRUE)
    expect_equal(!!result, c(
      "samples_to_tags",
      "features_to_samples",
      "genes_to_samples",
      "genes_samples_mutation",
      "samples",
      "patients_to_slides"
    ))
  })

})()