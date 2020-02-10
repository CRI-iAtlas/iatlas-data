load_all_samples <- function() {
  cat(crayon::magenta("Importing feather files for samples."), fill = TRUE)
  on.exit(cat(crayon::blue("Imported feather files for samples."), fill = TRUE))
  return(iatlas.data::read_iatlas_data_file(get_feather_file_folder(), "samples", join = TRUE))
}
