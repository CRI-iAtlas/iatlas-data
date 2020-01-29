build_samples_table <- function(feather_file_folder, all_samples) {

  iatlas.data::drop_table("genes_to_samples")
  iatlas.data::drop_table("features_to_samples")
  iatlas.data::drop_table("samples_to_tags")

  til_image_links <- read_iatlas_data_file(feather_file_folder, "/SQLite_data/til_image_links.feather")

  # Build the samples table.
  # Get only the sample names (no duplicates).
  cat(crayon::magenta("Building samples data."), fill = TRUE)
  samples <- all_samples %>%
    dplyr::distinct(sample) %>%
    dplyr::rename(name = sample) %>%
    merge(til_image_links, by.x = "name", by.y = "sample", all = TRUE) %>%
    dplyr::arrange(name) %>%
    dplyr::rename(tissue_id = link) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(tissue_id = stringi::stri_extract_first(tissue_id, regex = "[\\w]{4}-[\\w]{2}-[\\w]{4}-[\\w]{3}-[\\d]{2}-[\\w]{3}"))
  cat(crayon::blue("Built samples data."), fill = TRUE)

  .GlobalEnv$samples <- samples

  cat(crayon::magenta("Building the samples table."), fill = TRUE)
  samples %>% iatlas.data::replace_table("samples")
}