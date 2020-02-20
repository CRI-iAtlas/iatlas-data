# get_dupes <- function(df, keys) {
#   # return duplicated_records <- df %>% janitor::get_dupes(!!! rlang::syms(keys))
#   selected <- dplyr::select(df, !!! rlang::syms(keys))

#   if (anyDuplicated(selected) > 0) {
#     gc()
#     df %>% filter(duplicated(selected) | duplicated(selected, fromLast = TRUE))
#   } else {
#     gc()
#     dplyr::tibble()
#   }
# }

# get_dupes_true_vector uses some metaprogramming to create our custom.duplicated operation.
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
get_dupes_true_vector <- function(df, keys) {
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
  selected_true_vector <- get_dupes_true_vector(df, keys)
  gc()
  df %>% dplyr::filter(selected_true_vector)
}

resolve_df_dupes <- function(df, keys) {

  iatlas.data::timed(
    before_message = crayon::blue(paste0("Resolving partial-duplicates (", nrow(df), " records)...\n")),
    after_message = crayon::blue(paste0("Resolved partial-duplicates (", nrow(df), " records)")),
    {
      iatlas.data::timed(
        before_message = "  finding partial-duplicates\n",
        duplicated_records <- df %>% get_dupes(keys)
      )

      number_duplicates <- nrow(duplicated_records)

      cat(crayon::blue(paste0("  found ", number_duplicates, " duplicate records\n")))

      # If there are no duplicates, don't do further processing.
      if (number_duplicates > 0) {
        summarise_keys <- setdiff(names(df), keys)

        iatlas.data::timed(
          before_message = "  flattening partial-duplicates\n",
          deduplicated_records <- duplicated_records %>%
            dplyr::group_by(!!! rlang::syms(keys)) %>%
            dplyr::summarise_at(dplyr::vars(summarise_keys), iatlas.data::flatten_dupes)
        )

        cat(crayon::blue(paste0("  ", nrow(deduplicated_records), " de-duplicated records\n")))

        iatlas.data::timed(
          before_message = "  removing old partial-duplicates",
          clean_records <- df %>% dplyr::anti_join(deduplicated_records, by = keys)
        )

        cat(crayon::blue(paste0("  ", nrow(clean_records), " original records where not duplicated\n")))

        output <- clean_records %>% dplyr::bind_rows(deduplicated_records)
      } else {
        output <- df
      }

      cat(crayon::blue(paste0("  ", nrow(output), " resulting records\n")))

      return(output)
    }
  )
}
