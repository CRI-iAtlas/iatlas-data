build_known_gene_resolutions <- function() {
  cat_known_gene_resolutions_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  cat_known_gene_resolutions_status("Build known gene resolution tibble.")

  known_gene_resolutions <- dplyr::tibble(entrez = 16, official = "AARS1", alias = "AARS") %>%
    dplyr::add_row(entrez = 55, official = "ACP3", alias = "ACPP") %>%
    dplyr::add_row(entrez = 156, official = "GRK2", alias = "ADRBK1") %>%
    dplyr::add_row(entrez = 157, official = "GRK3", alias = "ADRBK2") %>%
    dplyr::add_row(entrez = 159, official = "ADSS2", alias = "ADSS") %>%
    dplyr::add_row(entrez = 166, official = "TLE5", alias = "AES") %>%
    dplyr::add_row(entrez = 202, official = "CRYBG1", alias = "AIM1") %>%
    dplyr::add_row(entrez = 251, official = "ALPG", alias = "ALPPL2") %>%
    dplyr::add_row(entrez = 374, official = "AREG", alias = "AREGB") %>%
    dplyr::add_row(entrez = 415, official = "ARSL", alias = "ARSE") %>%
    dplyr::add_row(entrez = 439, official = "GET3", alias = "ASNA1") %>%
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
    dplyr::add_row(entrez = 575, official = "ADGRB1", alias = "BAI1") %>%
    dplyr::add_row(entrez = 576, official = "ADGRB2", alias = "BAI2") %>%
    dplyr::add_row(entrez = 577, official = "ADGRB3", alias = "BAI3") %>%
    dplyr::add_row(entrez = 750, official = "GAS8-AS1", alias = "C16orf3") %>%
    dplyr::add_row(entrez = 755, official = "CFAP410", alias = "C21orf2") %>%
    dplyr::add_row(entrez = 833, official = "CARS1", alias = "CARS") %>%
    dplyr::add_row(entrez = 883, official = "KYAT1", alias = "CCBL1") %>%
    dplyr::add_row(entrez = 976, official = "ADGRE5", alias = "CD97") %>%
    dplyr::add_row(entrez = 1238, official = "ACKR2", alias = "CCBP2") %>%
    dplyr::add_row(entrez = 27202, official = "C5AR2", alias = "GPR77") %>%
    dplyr::add_row(entrez = 57007, official = "CXCR7", alias = "ACKR3") %>%
    dplyr::add_row(entrez = 51554, official = "ACKR4", alias = "CCRL1") %>%
    dplyr::add_row(entrez = 114902, official = "DEFB4B", alias = "CTRP5") %>%
    dplyr::add_row(entrez = 100289462, official = "DEFB4B", alias = "DEFB4P") %>%
    dplyr::add_row(entrez = 282618, official = "IFNL1", alias = "IL29") %>%
    dplyr::add_row(entrez = 282616, official = "IFNL2", alias = "IL28A") %>%
    dplyr::add_row(entrez = 282617, official = "IFNL3", alias = "IL28B") %>%
    dplyr::add_row(entrez = 163702, official = "IFNLR1", alias = "IL28RA") %>%
    dplyr::add_row(entrez = 79713, official = "IGFLR1", alias = "TMEM149") %>%
    dplyr::add_row(entrez = 5540, official = "NPY4R", alias = "PPYR1") %>%
    dplyr::add_row(entrez = 55848, official = "PLGRKT", alias = "C9orf46") %>%
    dplyr::add_row(entrez = 11251, official = "PTGDR2", alias = "GPR44") %>%
    dplyr::add_row(entrez = 257313, official = "UTS2B", alias = "UTS2D")

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$known_gene_resolutions <- known_gene_resolutions %>%
    feather::write_feather(paste0(getwd(), "/feather_files/known_gene_resolutions.feather"))

  ### Clean up ###
  # Data
  rm(known_gene_resolutions, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
  iatlas.data::pcawg_build_genes_files()
  iatlas.data::tcga_build_genes_files()
  iatlas.data::build_iatlas_db()
}
