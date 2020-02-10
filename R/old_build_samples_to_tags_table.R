old_build_samples_to_tags_table <- function() {
  all_samples <- old_get_all_samples()
  samples <- old_get_samples()

  cat(crayon::magenta("Building samples_to_tags data."), fill = TRUE)
  tags <- iatlas.data::read_table("tags") %>%
    dplyr::as_tibble() %>%
    dplyr::select(tag_id = id, name)

  sample_set_tcga_study <- all_samples %>%
    dplyr::distinct(sample, TCGA_Study) %>%
    dplyr::inner_join(tags, by = c("TCGA_Study" = "name"))

  sample_set_tcga_study <- sample_set_tcga_study %>%
    tibble::add_column(tag = "TCGA_Study") %>%
    dplyr::inner_join(tags %>% dplyr::rename(new_tag_id = tag_id), by = c("tag" = "name")) %>%
    tidyr::pivot_longer(c("tag_id", "new_tag_id"), names_to = "delete", values_to = "tag_id") %>%
    dplyr::distinct(sample, tag_id)

  sample_set_tcga_subtype <- all_samples %>%
    dplyr::distinct(sample, TCGA_Subtype) %>%
    dplyr::inner_join(tags, by = c("TCGA_Subtype" = "name"))

  sample_set_tcga_subtype <- sample_set_tcga_subtype %>%
    tibble::add_column(tag = "TCGA_Subtype") %>%
    dplyr::inner_join(tags %>% dplyr::rename(new_tag_id = tag_id), by = c("tag" = "name")) %>%
    tidyr::pivot_longer(c("tag_id", "new_tag_id"), names_to = "delete", values_to = "tag_id") %>%
    dplyr::distinct(sample, tag_id)

  sample_set_immune_subtype <- all_samples %>%
    dplyr::distinct(sample, Immune_Subtype) %>%
    dplyr::inner_join(tags, by = c("Immune_Subtype" = "name"))

  sample_set_immune_subtype <- sample_set_immune_subtype %>%
    tibble::add_column(tag = "Immune_Subtype") %>%
    dplyr::inner_join(tags %>% dplyr::rename(new_tag_id = tag_id), by = c("tag" = "name")) %>%
    tidyr::pivot_longer(c("tag_id", "new_tag_id"), names_to = "delete", values_to = "tag_id") %>%
    dplyr::distinct(sample, tag_id)

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
