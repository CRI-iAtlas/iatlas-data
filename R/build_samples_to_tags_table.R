build_samples_to_tags_table <- function(feather_file_folder, all_samples, samples) {
  cat(crayon::magenta("Building samples_to_tags data."), fill = TRUE)
  tags <- iatlas.data::read_table("tags") %>%
    dplyr::as_tibble() %>%
    dplyr::select(id, name)
  sample_set_tcga_study <- all_samples %>%
    dplyr::distinct(sample, TCGA_Study) %>%
    dplyr::inner_join(tags, by = c("TCGA_Study" = "name")) %>%
    dplyr::rename(tag_id = id) %>%
    dplyr::distinct(sample, tag_id)
  sample_set_tcga_subtype <- all_samples %>%
    dplyr::distinct(sample, TCGA_Subtype) %>%
    dplyr::inner_join(tags, by = c("TCGA_Subtype" = "name")) %>%
    dplyr::rename(tag_id = id) %>%
    dplyr::distinct(sample, tag_id)
  sample_set_immune_subtype <- all_samples %>%
    dplyr::distinct(sample, Immune_Subtype) %>%
    dplyr::inner_join(tags, by = c("Immune_Subtype" = "name")) %>%
    dplyr::rename(tag_id = id) %>%
    dplyr::distinct(sample, tag_id)
  samples_to_tags <- sample_set_tcga_study %>%
    dplyr::bind_rows(sample_set_tcga_subtype, sample_set_immune_subtype) %>%
    dplyr::inner_join(samples, by = c("sample" = "name")) %>%
    dplyr::distinct(id, tag_id) %>%
    dplyr::rename(sample_id = id)
  cat(crayon::blue("Built samples_to_tags data."), fill = TRUE)

  cat(crayon::magenta("Building samples_to_tags table."), fill = TRUE)
  samples_to_tags %>% iatlas.data::replace_table("samples_to_tags")
  cat(crayon::blue("Built samples_to_tags table. (", nrow(samples_to_tags), "rows )"), fill = TRUE, sep = " ")
}