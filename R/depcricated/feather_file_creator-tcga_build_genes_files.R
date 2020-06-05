tcga_build_genes_files <- function() {
  iatlas.data::set_feather_file_folder("feather_files")

  cat_genes_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_genes <- function(gene_type) {
    cat(crayon::magenta(paste0("Get tcga genes.")), fill = TRUE)

    cat_genes_status("Import gene_ids.")
    gene_ids <- iatlas.data::get_gene_ids() %>% dplyr::filter(!is.na(hgnc))

    cat_genes_status("Import driver mutation feather files for genes.")
    driver_mutations <- iatlas.data::get_tcga_driver_mutation_genes()

    cat_genes_status("Import immunomodulators feather files for genes.")
    immunomodulator_expr <- iatlas.data::get_tcga_immunomodulator_expr_genes()
    immunomodulators <- iatlas.data::get_tcga_immunodulator_genes()

    cat_genes_status("Import io_target feather files for genes.")
    io_target_expr <- iatlas.data::get_tcga_io_target_expr_genes()
    io_targets <- iatlas.data::get_tcga_io_target_genes()

    cat_genes_status("Import extra cellular network (ecn) feather files for genes.")
    ecns <- iatlas.data::get_tcga_ecn_genes()

    cat_genes_status("Bind gene expr data.")
    all_genes_expr <- driver_mutations %>%
      dplyr::bind_rows(immunomodulator_expr, io_target_expr) %>%
      dplyr::mutate(hgnc = ifelse(!is.na(hgnc), iatlas.data::trim_hgnc(hgnc), NA)) %>%
      dplyr::distinct(hgnc) %>%
      dplyr::arrange(hgnc)

    cat_genes_status("Bind ecn, immunomodulator, and io_target genes.")
    immunomodulators <- immunomodulators %>% dplyr::anti_join(io_targets, by = "hgnc")
    genes <- dplyr::bind_rows(immunomodulators, io_targets)
    genes <- ecns %>%
      dplyr::select(-c("type")) %>%
      dplyr::full_join(genes, by = "hgnc", suffix = c("",".y")) %>%
      dplyr::select(-dplyr::ends_with(".y")) %>%
      dplyr::distinct(hgnc, .keep_all = TRUE)

    cat_genes_status("Get copynumber results genes.")
    copy_number_results_genes <- iatlas.data::get_tcga_copynumber_results_cached() %>%
      dplyr::distinct(entrez)

    cat_genes_status("Add hgnc to copynumber results genes.")
    copy_number_results_genes <- gene_ids %>%
        dplyr::filter(entrez %in% copy_number_results_genes[["entrez"]]) %>%
        dplyr::distinct(entrez, hgnc) %>%
        dplyr::arrange(hgnc)

    cat_genes_status("Merge the copynumber results genes with the rest.")
    genes <- genes %>% dplyr::full_join(copy_number_results_genes, by = "hgnc") %>%
      dplyr::distinct(hgnc, .keep_all = TRUE) %>%
      dplyr::arrange(hgnc)

    cat_genes_status("Building all gene data.\n\t(Please be patient, this may take a little while.)")
    genes <- all_genes_expr %>%
      dplyr::full_join(genes, by = "hgnc") %>%
      dplyr::arrange(hgnc)

    cat_genes_status("Add genes that were missing.")
    genes <- genes %>% dplyr::left_join(
      missing_genes <- iatlas.data::read_iatlas_data_file(
        iatlas.data::get_feather_file_folder(),
        "SQLite_data/missing_genes.feather"
      ) %>%
        dplyr::select(hgnc, missing_entrez = entrez, missing_desc = description),
      by = "hgnc"
    ) %>%
      dplyr::mutate(
        description = ifelse(is.na(description), missing_desc, description),
        entrez = ifelse(is.na(entrez), missing_entrez, entrez)
      ) %>%
      dplyr::select(-c("missing_entrez", "missing_desc"))

    cat_genes_status("Add the entrez to the genes.")
    genes <- genes %>% dplyr::left_join(gene_ids %>% dplyr::rename(real_entrez = entrez), by = "hgnc") %>%
      dplyr::mutate(entrez = ifelse(is.na(entrez), real_entrez, entrez)) %>%
      dplyr::select(-real_entrez)

    cat_genes_status("Ensure the correct hgnc.")
    genes <- genes %>% dplyr::left_join(gene_ids %>% dplyr::rename(official = hgnc), by = "entrez") %>%
      dplyr::mutate(hgnc = ifelse(!is.na(official), official, hgnc)) %>%
      dplyr::select(-official)

    cat_genes_status("Remove / fix.")
    genes <- genes %>%
      # dplyr::rowwise() %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "ACKR2"), 1238, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "CXCR7"), 57007, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "ACKR4"), 51554, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "C1QTNF5"), 114902, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "C4B"), 721, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "C5AR2"), 27202, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "DEFB4B"), 100289462, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "IFNL1"), 282618, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "IFNL2"), 282616, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "IFNL3"), 282617, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "IFNLR1"), 163702, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "IGFLR1"), 79713, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "NPY4R"), 5540, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "PLGRKT"), 55848, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "PTGDR2"), 11251, entrez)) %>%
      # dplyr::mutate(entrez = ifelse(is.na(entrez) && identical(hgnc, "UTS2B"), 257313, entrez)) %>%
      dplyr::filter(!is.na(entrez))

    return(genes)
  }

  # Setting these to the GlobalEnv just for development purposes.
  .GlobalEnv$tcga_genes <- get_genes() %>%
    feather::write_feather(paste0(getwd(), "/feather_files/genes/tcga_genes.feather"))

  ### Clean up ###
  rm(tcga_genes, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
