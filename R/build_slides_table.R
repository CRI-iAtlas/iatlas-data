build_slides_table <- function() {

  # slides import ---------------------------------------------------
  cat(crayon::magenta("Importing feather files for slides."), fill = TRUE)
  slides <- get_all_samples() %>%
    dplyr::select(name = slide, description = slide_description) %>%
    dplyr::distinct(name, .keep_all = TRUE) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Imported feather files for slides."), fill = TRUE)

  # slides table ---------------------------------------------------
  cat(crayon::magenta("Building slides table."), fill = TRUE)
  slides %>% iatlas.data::replace_table("slides")
  cat(crayon::blue("Built the slides tables. (", nrow(slides), "rows )"), fill = TRUE, sep = " ")

}
