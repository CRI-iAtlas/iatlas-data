resolve_genes_to_samples_dupes <- function(genes_to_samples) {
  timed(
    before_message = "resolving genes_to_sample partial-duplicates...\n",
    after_message = "resolved genes_to_sample partial-duplicates",
    {
      timed(before_message = "  finding partial-duplicates", duplicated_records <- genes_to_samples %>% janitor::get_dupes(sample_id, gene_id, mutation_code_id))

      cat(crayon::blue(paste0("    ", nrow(duplicated_records), " duplicate records\n")))

      timed(
        before_message = "  flattening partial-duplicates",
        deduplicated_records <- duplicated_records %>%
          dplyr::group_by(sample_id, gene_id, mutation_code_id) %>%
          dplyr::summarise(
            status = flatten_dupes(group = .data, field = "status"),
            rna_seq_expr = flatten_dupes(group = .data, field = "rna_seq_expr")
          )
      )

      cat(crayon::blue(paste0("    ", nrow(deduplicated_records), " de-duplicated records\n")))

      timed(
        before_message = "  removing old partial-duplicates",
        clean_records <- dplyr::anti_join(genes_to_samples, deduplicated_records, by = c("sample_id" = "sample_id", "gene_id" = "gene_id", "mutation_code_id" = "mutation_code_id"))
      )

      cat(crayon::blue(paste0("    ", nrow(clean_records), " original records where not duplicated\n")))

      output <- dplyr::bind_rows(clean_records, deduplicated_records)

      cat(crayon::blue(paste0("    ", nrow(output), " resulting records\n")))

      output
    }
  )
}