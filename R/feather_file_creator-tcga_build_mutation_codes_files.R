tcga_build_mutation_codes_files <- function() {
  default_mutation_code <- "(NS)"

  cat_mutation_codes_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_codes <- function() {
    cat(crayon::magenta(paste0("Get mutation_codes.")), fill = TRUE)

    cat_mutation_codes_status("Import driver mutation feather files.")
    driver_mutations <- iatlas.data::get_tcga_driver_mutation_genes()

    cat_mutation_codes_status("Building mutation_codes data.")
    mutation_codes <- driver_mutations %>%
      dplyr::distinct(hgnc) %>%
      dplyr::mutate(code = ifelse(!is.na(hgnc), iatlas.data::old_get_mutation_code(hgnc), NA)) %>%
      dplyr::filter(!is.na(code)) %>%
      dplyr::add_row(code = default_mutation_code)

    cat_mutation_codes_status("Clean up the data set.")
    mutation_codes <- mutation_codes %>%
      dplyr::distinct(code) %>%
      dplyr::filter(!is.na(code)) %>%
      dplyr::arrange(code)

    return(mutation_codes)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_mutation_codes <- get_codes() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/mutation_codes/tcga_mutation_codes.feather"))

  ### Clean up ###
  rm(tcga_mutation_codes, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
