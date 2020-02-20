# ALTERNATIVE get_dupes options:
# janitor package solution:
#   get_dupes <- function(df, keys) {
#     janitor::get_dupes(df, !!! rlang::syms(keys))
#   }
#
# old, "common" solution:
#   get_dupes <- function(df, keys) {
#     selected <- dplyr::select(df, !!! rlang::syms(keys))
#     if (anyDuplicated(selected) > 0)
#           df %>% filter(duplicated(selected) | duplicated(selected, fromLast = TRUE))
#     else  dplyr::tibble()
#   }

# get_dupes_truth_vector uses some metaprogramming to create our custom.duplicated operation.
# Basically, it takes the keys and creates tests to compare each row with the lagging and leading row (prev/next respectively)
# and see if they are duplicates for the given key values.
# EXAMPLE:
#   for these keys: c("entrez", "sample", "mutation_code")
#   the generated code is:
#     selected <- sorted %>%
#       dplyr::transmute(
#         id = id,
#         duplicate =
#           (
#             present_equal(entrez,         lag(entrez)) &
#             present_equal(sample,         lag(sample)) &
#             present_equal(mutation_code,  lag(mutation_code))
#           ) |
#           (
#             present_equal(entrez,         lead(entrez)) &
#             present_equal(sample,         lead(sample)) &
#             present_equal(mutation_code,  lead(mutation_code))
#           )
#       ) %>%
#       dplyr::arrange(id)
get_dupes_truth_vector <- function(df, keys) {
  present_equal <- function(a, b) ifelse(!is.na(a) & !is.na(b), a == b, F)
  key_syms <- rlang::syms(keys)

  selected_true_vector <- (
    eval(parse(text = paste0(
      "df %>%
      dplyr::select(!!!key_syms) %>%
      tibble::rowid_to_column('id') %>%
      dplyr::arrange(!!!key_syms) %>%
      dplyr::transmute(id = id, duplicate = (",
        paste(keys %>% purrr::map(~ paste0("present_equal(", .x, ", dplyr::lag(", .x, "))")), collapse = ' & '),
      ") | (",
        paste(keys %>% purrr::map(~ paste0("present_equal(", .x, ", dplyr::lead(", .x, "))")), collapse = ' & '),
      "))"
    ))) %>%
    dplyr::arrange(id)
  )$duplicate
}

# get_dupes does the same thing as janitor::get_dupes, but it's > 5x faster for large data sets and uses less memory
get_dupes <- function(df, keys) {
  selected_true_vector <- get_dupes_truth_vector(df, keys)
  gc()
  df %>% dplyr::filter(selected_true_vector)
}
