(function() {
  library("testthat")
  library('feather')
  source('./lib_test_data.R')

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
  # Contents of the get_tag_column_names.feather:
    # (
    #   name = c("Good Name"),
    #   tag = c("tag"),
    #   tag.01 = c("tag.01"),
    #   tag.11 = c("tag.11"),
    #   tag.x = c("tag.x"),
    #   description = c("Good description")
    # )
  test_that("get_tag_column_names returns a character vector of column names that beging with 'tag'.", {
    data_frame <- read_test_feather("get_tag_column_names.feather")
    result <- get_tag_column_names(data_frame)
    expect_that(result[1], is_identical_to("tag"))
    # expect_that(result[2], is_identical_to("tag.01"))
    # expect_that(result[3], is_identical_to("tag.11"))
    # expect_that(result[4], is_identical_to("tag.x"))
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

  # load_feather_data ---------------------------------------------------
  test_that("load_feather_data", {
    first <- read_test_feather("load_feather_data_set/first.feather")
    second <- read_test_feather("load_feather_data_set/second.feather")
    results <- load_feather_data(get_test_data_path("load_feather_data_set"))
    expect_equal(nrow(results), nrow(first) + nrow(second))
  })

  # load_feather_files ---------------------------------------------------
  test_that("load_feather_files returns an empty data frame if the file or folder doesn't exist.", {
    folder <- "not_a_folder_or_file"
    result <- load_feather_files(Sys.glob(paste0(folder, "/*.feather")))
    expect_that(is_df_empty(result), is_identical_to(TRUE))
    result <- load_feather_files(Sys.glob(paste0(folder, "/*.feather")), join = TRUE)
    expect_that(is_df_empty(result), is_identical_to(TRUE))
  })

  # read_iatlas_data_file ---------------------------------------------------
  test_that("read_iatlas_data_file with directory", {
    first <- read_test_feather("load_feather_data_set/first.feather")
    second <- read_test_feather("load_feather_data_set/second.feather")
    results <- iatlas.data::read_iatlas_data_file(test_data_folder, "load_feather_data_set")
    expect_equal(nrow(results), nrow(first) + nrow(second))
  })
  test_that("read_iatlas_data_file with glob", {
    first <- read_test_feather("load_feather_data_set/first.feather")
    second <- read_test_feather("load_feather_data_set/second.feather")
    results <- iatlas.data::read_iatlas_data_file(test_data_folder, "load_feather_data_set/*.feather")
    expect_equal(nrow(results), nrow(first) + nrow(second))
  })

  # rebuild_gene_relational_data ---------------------------------------------------
  test_that("rebuild_gene_relational_data returns unique, non-na values from column", {
    all_genes <- read_test_feather("features.feather")
    all_genes %>%
    rebuild_gene_relational_data("class", "name") %>% nrow %>%
    expect_equal(13)

    all_genes %>%
    rebuild_gene_relational_data("display", "name") %>% nrow %>%
    expect_equal(84)
  })
  test_that("rebuild_gene_relational_data returns sorted results", {
    all_genes <- read_test_feather("features.feather")
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
