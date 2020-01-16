# Ensure magrittr is installed.
# if (!'magrittr' %in% installed.packages()) {
#   install.packages("magrittr")
# }

# Ensure RPostgres is installed.
# if (!'RPostgres' %in% installed.packages()) {
#   install.packages("RPostgres")
# }

# Load magrittr so %>% is available.
# library("magrittr")

# Make the custom data functions available.
# source("../../R/data_functions.R", chdir = TRUE)

# filter_na
(function() {
  library("testthat")
  library('feather')

  test_that("filter_na returns the value when the passed value is NOT NA.", {
    expect_that(filter_na(c(14)), is_identical_to(14))
    expect_that(filter_na(14), is_identical_to(14))
  })
  test_that("filter_na returns the value when the passed value is combined with an NA.", {
    expect_that(filter_na(c(14, NA)), is_identical_to(14))
  })
  test_that("filter_na returns NA when there is no passed value or the passed value is NA.", {
    cat("value:", filter_na(NA), fill = TRUE, sep = " ")
    expect_that(filter_na(), is_identical_to(NA %>% as.character))
    expect_that(filter_na(NA), is_identical_to(NA %>% as.character))
  })

  # get_tag_column_names
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
    data_frame <- feather::read_feather("../test_data/get_tag_column_names.feather")
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

  # is_df_empty
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

  # link_to_references
  test_that("link_to_references returns NA when no value present.", {
    expect_that(link_to_references(NA), is_identical_to(NA))
  })
  test_that("link_to_references returns NA when URL value is 'NA'.", {
    link <- '<a href="NA">NA</a>'
    expect_that(link_to_references(link), is_identical_to(NA))
  })
  test_that("link_to_references returns NA when there is no URL.", {
    link <- '<a href>NA</a>'
    expect_that(link_to_references(link), is_identical_to(NA))
  })
  test_that("link_to_references returns a url in curly braces.", {
    url <- 'http://someplace.com?query=yes#pow'
    link <- paste0('<a href="', url, '"></a>', sep = "")
    expected <- paste0('{', url, '}', sep = "")
    expect_that(link_to_references(link), is_identical_to(expected))
  })

  # switch_value
  test_that("switch_value returns NA when no value present.", {
    reference <- dplyr::tibble(gene = c("1", "2", "3"), scoobs = c(NA, NA, NA))
    some_object <- dplyr::tibble(gene = c("", "", ""), scoobs = c("4", "5", "6"))
    result <- switch_value(reference[1,], "gene", "scoobs", some_object)

    expect_that(result, is_identical_to(NA))
  })
  test_that("switch_value returns the value from the second object.", {
    reference <- dplyr::tibble(gene = c("1", "2", "3"), scoobs = c(NA, NA, NA))
    some_object <- dplyr::tibble(gene = c("1", "", ""), scoobs = c("4", "5", "6"))
    result <- switch_value(reference[1,], "gene", "scoobs", some_object)

    expect_that(result, is_identical_to("4"))
  })

  test_that("driver_results_label_to_hgnc extracts the hugo-id", {
    expect_that(driver_results_label_to_hgnc("RQCD1 P131L;SKC"), is_identical_to("RQCD1 P131L"))
    expect_that(driver_results_label_to_hgnc("APC R213*;COAD"), is_identical_to("APC R213*"))
  })

  test_that("driver_results_label_to_hgnc returns NA for bad data", {
    expect_that(driver_results_label_to_hgnc("NA;SKC"), is_identical_to(NA))
    expect_that(driver_results_label_to_hgnc(""), is_identical_to(NA))
    expect_that(driver_results_label_to_hgnc(NA), is_identical_to(NA))
    expect_that(driver_results_label_to_hgnc(";SKC"), is_identical_to(NA))
  })

  test_that("load_feather_data", {
    first <- feather::read_feather("../test_data/load_feather_data_set/first.feather")
    second <- feather::read_feather("../test_data/load_feather_data_set/second.feather")
    results <- load_feather_data("../test_data/load_feather_data_set")
    expect_equal(nrow(results), nrow(first) + nrow(second))
  })

  test_that("rebuild_gene_relational_data returns unique, non-na values from column", {
    all_genes <- read_feather("../test_data/features.feather")
    all_genes %>%
    rebuild_gene_relational_data("class", "name") %>% nrow %>%
    expect_equal(13)

    all_genes %>%
    rebuild_gene_relational_data("display", "name") %>% nrow %>%
    expect_equal(84)
  })

  test_that("rebuild_gene_relational_data returns sorted results", {
    all_genes <- read_feather("../test_data/features.feather")
    random_order_genes <- all_genes[sample(1:nrow(all_genes)),]

    expect_false(isTRUE(all.equal(all_genes, random_order_genes, ignore_row_order = FALSE)))

    expect_true(isTRUE(all.equal(
      all_genes %>% rebuild_gene_relational_data("class", "name"),
      random_order_genes %>% rebuild_gene_relational_data("class", "name"),
      ignore_row_order = FALSE))
    )

  })
})()