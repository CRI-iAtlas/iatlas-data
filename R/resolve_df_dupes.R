get_dupes <- function(df, keys) {
  # return duplicated_records <- df %>% janitor::get_dupes(!!! rlang::syms(keys))
  selected <-
    df %>%
    dplyr::select(!!! rlang::syms(keys))

  if (anyDuplicated(selected) > 0) {
    first_pass <- selected %>% duplicated()
    second_pass <- selected %>% duplicated(fromLast = TRUE)

    df %>% subset(first_pass | second_pass)
  } else {
    dplyr::tibble()
  }
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

        cat(crayon::blue(paste0("    ", nrow(clean_records), " original records where not duplicated\n")))

        output <- clean_records %>% dplyr::bind_rows(deduplicated_records)
      } else {
        output <- df
      }

      cat(crayon::blue(paste0("    ", nrow(output), " resulting records\n")))

      return(output)
    }
  )
}
