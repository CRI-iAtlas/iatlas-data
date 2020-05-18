(function() {
  library("testthat")
  library('feather')
  source('./lib_test_data.R')

  # build_references ---------------------------------------------------
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

  # filter_na ---------------------------------------------------
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

  # old_get_mutation_code ---------------------------------------------------
  test_that("old_get_mutation_code returns NA when no value present.", {
    expect_that(old_get_mutation_code(NA), is_identical_to(NA))
  })
  test_that("old_get_mutation_code returns all text after the first space.", {
    hgnc <- "plokij uhygtf knowledge"
    expected <- "uhygtf knowledge"
    expect_that(old_get_mutation_code(hgnc), is_identical_to(expected))
  })
  test_that("old_get_mutation_code returns NA as there are no spaces.", {
    hgnc <- "plokij"
    expect_that(old_get_mutation_code(hgnc), is_identical_to(NA))
  })
  test_that("old_get_mutation_code returns a list of strings.", {
    hgncs <- c("plokijuh", "uhygtf plokij knowledge", "knowledge")
    expected <- c(NA, "plokij knowledge", NA)
    expect_that(old_get_mutation_code(hgncs), is_identical_to(expected))
  })

  # link_to_references ---------------------------------------------------
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

  # driver_results_label_to_hgnc ---------------------------------------------------
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

  # validate_dupes ---------------------------------------------------
  test_that("test validate_dupes defaults", {
    validate_dupes(1) %>%
      expect_equal(1)
  })
  test_that("test validate dupes when values in group are equal", {
    values <- list("a" = c(2,2), "b" = c(1,1), "c" = c(NA,4))
    validate_dupes(1,values,c("a","b")) %>%
      expect_equal(1)
  })
  test_that("test validate dupes when values in group have conflicts", {
    values <- list("a" = c(2,2), "b" = c(1,3), "c" = c(NA,4))
    expect_error(validate_dupes(1,values,c("a","b"),c("c")))
  })

  # trim_hgnc ---------------------------------------------------
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

  # flatten_tags ---------------------------------------------------
  test_that("flatten_tags", {
    before_records <- read_test_csv("flatten_tags/before_records.csv")
    tags_to_tags <- read_test_csv("flatten_tags/tags_to_tags.csv")
    after_records <- read_test_csv("flatten_tags/after_records.csv")
    expect_equal(TRUE, dplyr::all_equal(
      after_records,
      flatten_tags(before_records, tags_to_tags, "gene_id")
    ))
  })

  # create_gene_expression_lookup ---------------------------------------------------
  test_that("create_gene_expression_lookup returns the right values from the sample matrix",{
    sample_matrix <- feather::read_feather("../test_data/RNASeqV2Sample.feather")
    lookup <- create_gene_expression_lookup(sample_matrix)
    expect_equal(lookup("A1CF","TCGA-OR-A5J2-01A-11R-A29S-07"), 0)
    expect_equal(lookup("A2BP1","TCGA-OR-A5J2-01A-11R-A29S-07"), 5.6368)
    expect_equal(lookup("AACS","TCGA-OR-A5JA-01A-11R-A29S-07"), 2354.6500)
  })
  test_that("create_gene_expression_lookup returns NA when gene_id or sample_id do not exist in the data",{
    sample_matrix <- feather::read_feather("../test_data/RNASeqV2Sample.feather")
    lookup <- create_gene_expression_lookup(sample_matrix)
    expect_equal(lookup("ABCDEF","TCGA-OR-A5J2-01A-11R-A29S-07"), NA)
    expect_equal(lookup("A2BP1","TCGA-OR-B5J9-01A-11R-A29S-07"), NA)
    expect_equal(lookup("GENE_ID","SAMPLE_ID"), NA)
  })

})()
