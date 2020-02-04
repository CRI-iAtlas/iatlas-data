build_slides_table <- function() {
  cat(crayon::magenta("Building slides data."), fill = TRUE)

  # Import feather files for samples.
  slides <- get_all_samples() %>%
    dplyr::select(name = slide, description = slide_description) %>%
    dplyr::distinct(name, .keep_all = TRUE) %>%
    dplyr::arrange(name)

  # slides table ---------------------------------------------------
  slides %>% iatlas.data::replace_table("slides")

  cat(crayon::blue("Built the slides tables. (", nrow(slides), "rows )"), fill = TRUE, sep = " ")
}
