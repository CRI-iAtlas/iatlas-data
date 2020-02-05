(function() {
  library("testthat")
  library('feather')
  source('./lib_test_data.R')

  # build_references
  test_that("build_references returns NA when no value present.", {
    expect_that(build_references(NA), is_identical_to(NA))
  })
  test_that("build_references returns NA when reference value is 'NA'.", {
    reference <- 'NA'
    expect_that(build_references(reference), is_identical_to(NA))
  })
  test_that("build_references returns a comma separated list of references in curly braces.", {
    reference <- "http://someplace.com?query=yes#pow | http://otherplace.com?query=yes#pow"
    expected <- '{http://someplace.com?query=yes#pow,http://otherplace.com?query=yes#pow}'
    expect_that(build_references(reference), is_identical_to(expected))
  })
  test_that("build_references returns a list of references in curly braces.", {
    reference <- c("http://someplace.com?query=yes#pow", "http://otherplace.com?query=yes#pow")
    expected <- c("{http://someplace.com?query=yes#pow}", "{http://otherplace.com?query=yes#pow}")
    expect_that(build_references(reference), is_identical_to(expected))
  })

  # filter_na
  test_that("filter_na returns the value when the passed value is NOT NA.", {
    expect_that(filter_na(c(14)), is_identical_to(14))
    expect_that(filter_na(14), is_identical_to(14))
  })

  test_that("filter_na returns the value when the passed value is combined with an NA.", {
    expect_that(filter_na(c(14, NA)), is_identical_to(14))
  })

  test_that("filter_na returns NA when there is no passed value or the passed value is NA.", {
    expect_that(filter_na(), is_identical_to(NA %>% as.character))
    expect_that(filter_na(NA), is_identical_to(NA %>% as.character))
  })

  # get_mutation_code
  test_that("get_mutation_code returns NA when no value present.", {
    expect_that(get_mutation_code(NA), is_identical_to(NA))
  })
  test_that("get_mutation_code returns all text after the first space.", {
    hgnc <- "plokij uhygtf knowledge"
    expected <- "uhygtf knowledge"
    expect_that(get_mutation_code(hgnc), is_identical_to(expected))
  })
  test_that("get_mutation_code returns NA as there are no spaces.", {
    hgnc <- "plokij"
    expect_that(get_mutation_code(hgnc), is_identical_to(NA))
  })
  test_that("get_mutation_code returns a list of strings.", {
    hgncs <- c("plokijuh", "uhygtf plokij knowledge", "knowledge")
    expected <- c(NA, "plokij knowledge", NA)
    expect_that(get_mutation_code(hgncs), is_identical_to(expected))
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
    first <- read_test_feather("load_feather_data_set/first.feather")
    second <- read_test_feather("load_feather_data_set/second.feather")
    results <- load_feather_data(get_test_data_path("load_feather_data_set"))
    expect_equal(nrow(results), nrow(first) + nrow(second))
  })

  test_that("read_iatlas_data_file with directory", {
    first <- read_test_feather("load_feather_data_set/first.feather")
    second <- read_test_feather("load_feather_data_set/second.feather")
    results <- read_iatlas_data_file(test_data_folder, "load_feather_data_set")
    expect_equal(nrow(results), nrow(first) + nrow(second))
  })

  test_that("read_iatlas_data_file with glob", {
    first <- read_test_feather("load_feather_data_set/first.feather")
    second <- read_test_feather("load_feather_data_set/second.feather")
    results <- read_iatlas_data_file(test_data_folder, "load_feather_data_set/*.feather")
    expect_equal(nrow(results), nrow(first) + nrow(second))
  })

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

  test_that("test validate dupes defaults", {
    validate_dupes(1) %>%
    expect_equal(1)
  })

  test_that("test validate dupes when values in group are equal", {
    values <- list("a" = c(2,2), "b" = c(1,1), "c" = c(NA,4))
    validate_dupes(1,values,c("a","b")) %>%
    expect_equal(1)
  })

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

  # trim_hgnc
  test_that("trim_hgnc returns NA when no value present.", {
    expect_that(trim_hgnc(NA), is_identical_to(NA))
  })
  test_that("trim_hgnc returns only the text up to the first space.", {
    hgnc <- "plokij uhygtf knowledge"
    expected <- "plokij"
    expect_that(trim_hgnc(hgnc), is_identical_to(expected))
  })
  test_that("trim_hgnc returns the passed string as there are no spaces.", {
    hgnc <- "plokij"
    expect_that(trim_hgnc(hgnc), is_identical_to(hgnc))
  })
  test_that("trim_hgnc returns a list of strings.", {
    hgncs <- c("plokijuh", "uhygtf plokij knowledge", "knowledge")
    expected <- c("plokijuh", "uhygtf", "knowledge")
    expect_that(trim_hgnc(hgncs), is_identical_to(expected))
  })

  test_that("test validate dupes when values in group have conflicts", {
    values <- list("a" = c(2,2), "b" = c(1,3), "c" = c(NA,4))
    expect_error(validate_dupes(1,values,c("a","b"),c("c")))
  })

  test_that("flatten_tags", {
    before_records <- read_test_csv("flatten_tags/before_records.csv")
    tags_to_tags <- read_test_csv("flatten_tags/tags_to_tags.csv")
    after_records <- read_test_csv("flatten_tags/after_records.csv")
    expect_equal(TRUE, dplyr::all_equal(
      after_records,
      flatten_tags(before_records, tags_to_tags, "gene_id")
    ))
  })

})()
