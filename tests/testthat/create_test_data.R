load_save_n_random_records <- function(src_feathers, dst_feathers, file, n_records = 100) {
  feather::read_feather(paste0(src_feathers, "/", file)) %>%
  dplyr::sample_n(n_records) %>%
  feather::write_feather(paste0(dst_feathers, "/", file))
}

create_test_data <- function () {
  files = c(
    "edges/edges_TCGASubtype.feather",
    "edges/edges_TCGAStudy.feather",
    "edges/edges_TCGAImmune.feather",
    "edges/edges_TCGAStudy_Immune.feather",

    "./driver_results/driver_results_01.feather",
    "./driver_results/driver_results_02.feather",
    "./driver_results/driver_results_03.feather",

    "./relationships/features_to_samples/features_to_samples_03.feather",
    "./relationships/features_to_samples/features_to_samples_02.feather",
    "./relationships/features_to_samples/features_to_samples_01.feather",

    "./relationships/samples_to_tags/samples_to_tags_02.feather",
    "./relationships/samples_to_tags/samples_to_tags_03.feather",
    "./relationships/samples_to_tags/samples_to_tags_01.feather",

    "./relationships/genes_samples_mutations/genes_samples_mutations_03.feather",
    "./relationships/genes_samples_mutations/genes_samples_mutations_02.feather",
    "./relationships/genes_samples_mutations/genes_samples_mutations_01.feather"
  )

  for(file in files) {
    cat(paste0("converting: ", file, "\n"))
    load_save_n_random_records('./feather_files', './tests/test_data/feather_files', file)
  }
}