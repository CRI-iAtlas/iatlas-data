tcga_build_gene_types_files <- function() {

  cat_gene_types_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_types <- function() {

    cat(crayon::magenta(paste0("Get TCGA gene types")), fill = TRUE)

    cat_gene_types_status("Building gene_types data.")
    gene_types <- dplyr::tibble(
      name = c("immunomodulator", "io_target", "extra_cellular_network"),
      display = c("Immunomodulator", "IO Target", "Extra Cellular Network")
    )

    return(gene_types)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_gene_types <- get_types() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/gene_types/tcga_gene_types.feather"))

  ### Clean up ###
  # Data
  rm(tcga_gene_types, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
