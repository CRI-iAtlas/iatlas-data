(function() {
  test_that("present(vector()) is true", {expect_true(present(vector()))})

  test_that("present('abc') is true", {expect_true(present('abc'))})
  test_that("present('') is true", {expect_true(present(''))})
  test_that("present(list()) is true", {expect_true(present(list()))})
  test_that("present(FALSE) is true", {expect_true(present(FALSE))})
  test_that("present(NA) is false", {expect_false(present(NA))})
  test_that("present(NULL) is false", {expect_false(present(NULL))})

  test_that("timed returns what you pass in", {expect_equal(timed(123), 123)})
  test_that("timed before_message", {expect_equal(timed(123, before_message = "hi"), 123)})
  test_that("timed after_message", {expect_equal(timed(123, after_message = "hi"), 123)})
  test_that("timed message", {expect_equal(timed(123, message = "hi"), 123)})

  # get_tag_column_names ---------------------------------------------------
  test_that("get_tag_column_names returns a character vector of column names that beging with 'tag'.", {
    data_frame <- synapse_read_feather_file("syn22216459")
    result <- iatlas.data::get_tag_column_names(data_frame)
    expect_identical(result, c("tag", "tag_01"))
  })
  test_that("get_tag_column_names returns NA when an empty data frame, NULL, or NA is passed.", {
    data_frame <- dplyr::tibble()
    expect_that(get_tag_column_names(data_frame), is_identical_to(NA))
    expect_that(get_tag_column_names(NULL), is_identical_to(NA))
    expect_that(get_tag_column_names(NA), is_identical_to(NA))
  })

  # is_df_empty ---------------------------------------------------
  test_that("is_df_empty returns FALSE when a valid non-empty dataframe or tibble is passed.", {
    expect_that(is_df_empty(cars), is_identical_to(FALSE))
    expect_that(is_df_empty(cars %>% dplyr::as_tibble()), is_identical_to(FALSE))
  })
  test_that("is_df_empty returns TRUE when an empty dataframe, empty tibble, NA, NULL, or no data frame is passed.", {
    expect_that(is_df_empty(data.frame()), is_identical_to(TRUE))
    expect_that(is_df_empty(NA), is_identical_to(TRUE))
    expect_that(is_df_empty(NULL), is_identical_to(TRUE))
    expect_that(is_df_empty(), is_identical_to(TRUE))
  })

  # rebuild_gene_relational_data ---------------------------------------------------
  test_that("rebuild_gene_relational_data returns unique, non-na values from column", {
    all_genes <- synapse_read_feather_file("syn22216489")
    all_genes %>%
    rebuild_gene_relational_data("class", "name") %>% nrow %>%
    expect_equal(13)

    all_genes %>%
    rebuild_gene_relational_data("display", "name") %>% nrow %>%
    expect_equal(84)
  })
  test_that("rebuild_gene_relational_data returns sorted results", {
    all_genes <- synapse_read_feather_file("syn22216489")
    random_order_genes <- all_genes[sample(1:nrow(all_genes)),]

    expect_false(isTRUE(all.equal(all_genes, random_order_genes, ignore_row_order = FALSE)))

    expect_true(isTRUE(all.equal(
      all_genes %>% rebuild_gene_relational_data("class", "name"),
      random_order_genes %>% rebuild_gene_relational_data("class", "name"),
      ignore_row_order = FALSE))
    )
  })

  # get_unique_valid_values ---------------------------------------------------
  test_that("get_unique_valid_values removes NAs", {
    get_unique_valid_values(c(NA,1,NA,2,NA,NA)) %>%
      expect_equal(c(1,2))
  })
  test_that("get_unique_valid_values removes dupes", {
    get_unique_valid_values(c(1,2,1,1,2,3)) %>%
      expect_equal(c(1,2,3))
  })
  test_that("get_unique_valid_values removes dupes and NAs", {
    get_unique_valid_values(c(1,2,1,NA,1,2,NA,3)) %>%
      expect_equal(c(1,2,3))
  })

})()
