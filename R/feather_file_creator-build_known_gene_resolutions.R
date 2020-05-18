build_known_gene_resolutions <- function() {
  cat_known_gene_resolutions_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  cat_known_gene_resolutions_status("Build known gene resolution tibble.")

  known_gene_resolutions <- dplyr::tibble(entrez = 16, official = "AARS1", alias = "AARS") %>%
    dplyr::add_row(entrez = 55, official = "ACP3", alias = "ACPP") %>%
    dplyr::add_row(entrez = 156, official = "GRK2", alias = "ADRBK1") %>%
    dplyr::add_row(entrez = 166, official = "TLE5", alias = "AES") %>%
    dplyr::add_row(entrez = 251, official = "ALPG", alias = "ALPPL2") %>%
    dplyr::add_row(entrez = 498, official = "ATP5F1A", alias = "ATP5A1") %>%
    dplyr::add_row(entrez = 506, official = "ATP5F1B", alias = "ATP5B") %>%
    dplyr::add_row(entrez = 509, official = "ATP5F1C", alias = "ATP5C1") %>%
    dplyr::add_row(entrez = 513, official = "ATP5F1D", alias = "ATP5D") %>%
    dplyr::add_row(entrez = 514, official = "ATP5F1E", alias = "ATP5E") %>%
    dplyr::add_row(entrez = 515, official = "ATP5PB", alias = "ATP5F1") %>%
    dplyr::add_row(entrez = 516, official = "ATP5MC1", alias = "ATP5G1") %>%
    dplyr::add_row(entrez = 517, official = "ATP5MC2", alias = "ATP5G2") %>%
    dplyr::add_row(entrez = 518, official = "ATP5MC3", alias = "ATP5G3") %>%
    dplyr::add_row(entrez = 521, official = "ATP5ME", alias = "ATP5I") %>%
    dplyr::add_row(entrez = 522, official = "ATP5PF", alias = "ATP5J") %>%
    dplyr::add_row(entrez = 539, official = "ATP5PO", alias = "ATP5O") %>%
    dplyr::add_row(entrez = 755, official = "CFAP410", alias = "C21orf2") %>%
    dplyr::add_row(entrez = 833, official = "CARS1", alias = "CARS")

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$known_gene_resolutions <- known_gene_resolutions %>%
    feather::write_feather(paste0(getwd(), "/feather_files/known_gene_resolutions.feather"))

  ### Clean up ###
  # Data
  rm(known_gene_resolutions, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
