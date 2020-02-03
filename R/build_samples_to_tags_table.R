build_samples_to_tags_table <- function() {
  all_samples_with_patient_ids <- get_all_samples_with_patient_ids()
  samples <- get_samples()

  cat(crayon::magenta("Building samples_to_tags data."), fill = TRUE)
  tags <- iatlas.data::read_table("tags") %>%
    dplyr::as_tibble() %>%
    dplyr::select(id, name)

  sample_set_tcga_study <- all_samples_with_patient_ids %>%
    dplyr::distinct(sample, TCGA_Study) %>%
    dplyr::inner_join(tags, by = c("TCGA_Study" = "name")) %>%
    dplyr::distinct(sample, tag_id = id)

  sample_set_tcga_subtype <- all_samples_with_patient_ids %>%
    dplyr::distinct(sample, TCGA_Subtype) %>%
    dplyr::inner_join(tags, by = c("TCGA_Subtype" = "name")) %>%
    dplyr::distinct(sample, tag_id = id)

  sample_set_immune_subtype <- all_samples_with_patient_ids %>%
    dplyr::distinct(sample, Immune_Subtype) %>%
    dplyr::inner_join(tags, by = c("Immune_Subtype" = "name")) %>%
    dplyr::distinct(sample, tag_id = id)

  samples_to_tags <- dplyr::bind_rows(
    sample_set_tcga_study,
    sample_set_tcga_subtype,
    sample_set_immune_subtype
  ) %>%
    dplyr::inner_join(samples, by = c("sample" = "name")) %>%
    dplyr::distinct(sample_id = id, tag_id)
  cat(crayon::blue("Built samples_to_tags data."), fill = TRUE)

  # samples_to_tags table ---------------------------------------------------
  cat(crayon::magenta("Building samples_to_tags table."), fill = TRUE)
  samples_to_tags %>% iatlas.data::replace_table("samples_to_tags")
  cat(crayon::blue("Built samples_to_tags table. (", nrow(samples_to_tags), "rows )"), fill = TRUE, sep = " ")
}