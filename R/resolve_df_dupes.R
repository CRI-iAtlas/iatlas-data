resolve_df_dupes <- function(df, keys) {

      cat(crayon::blue(paste0("    ", nrow(df), " original records to check\n")))
  timed(
    before_message = paste0("resolving ", deparse(substitute(df)), " partial-duplicates...\n"),
    after_message = paste0("resolved ", deparse(substitute(df)), " partial-duplicates"),
    {
      timed(
        before_message = "  finding partial-duplicates\n",
        duplicated_records <- df %>% janitor::get_dupes(!!! rlang::syms(keys))
      )

      cat(crayon::blue(paste0("    ", nrow(duplicated_records), " duplicate records\n")))

      summarise_keys <- setdiff(names(df), keys)

      timed(
        before_message = "  flattening partial-duplicates\n",
        deduplicated_records <- duplicated_records %>%
          dplyr::group_by(!!! rlang::syms(keys)) %>%
          dplyr::summarise_at(dplyr::vars(summarise_keys), iatlas.data::flatten_dupes)
      )

      cat(crayon::blue(paste0("    ", nrow(deduplicated_records), " de-duplicated records\n")))

      timed(
        before_message = "  removing old partial-duplicates",
        clean_records <- df %>% dplyr::anti_join(deduplicated_records, by = keys)
      )

      cat(crayon::blue(paste0("    ", nrow(clean_records), " original records where not duplicated\n")))

      output <- clean_records %>% dplyr::bind_rows(deduplicated_records)

      cat(crayon::blue(paste0("    ", nrow(output), " resulting records\n")))

      output
    }
  )
}
