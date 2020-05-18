tcga_build_genes_files <- function() {
  iatlas.data::set_feather_file_folder("feather_files")

  cat_genes_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_genes <- function(gene_type) {
    cat(crayon::magenta(paste0("Get tcga genes.")), fill = TRUE)

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
    copy_number_results_genes <- iatlas.data::timed(
      before_message = crayon::magenta("Importing HUGE RNA Seq Expr file.\n(This is VERY large and may take some time to open. Please be patient.)\n"),
      after_message = crayon::blue("Imported HUGE RNA Seq Expr file."),
      iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "EBPlusPlusAdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.feather") %>%
        dplyr::as_tibble() %>%
        tidyr::separate(gene_id, c("hgnc", "entrez"), sep = "[|]") %>%
        dplyr::mutate_at(dplyr::vars(entrez), as.numeric) %>%
        dplyr::select(entrez, hgnc) %>%
        dplyr::filter(hgnc != "?") %>%
        dplyr::filter(entrez %in% copy_number_results_genes[["entrez"]]) %>%
        iatlas.data::resolve_hgnc_conflicts() %>%
        dplyr::distinct(hgnc) %>%
        dplyr::arrange(hgnc)
    )

    cat_genes_status("Merge the copynumber results genes with the rest.")
    genes <- genes %>% dplyr::full_join(copy_number_results_genes, by = "hgnc") %>%
      dplyr::distinct(hgnc, .keep_all = TRUE) %>%
      dplyr::arrange(hgnc)

    cat_genes_status("Building all gene data.\n\t(Please be patient, this may take a little while.)")
    genes <- all_genes_expr %>%
      dplyr::full_join(genes, by = "hgnc") %>%
      dplyr::arrange(hgnc)
    genes <- genes %>% dplyr::left_join(
      iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "gene_ids.feather"),
      by = "hgnc"
    )
    genes <- genes %>% dplyr::left_join(
      iatlas.data::read_iatlas_data_file(iatlas.data::get_feather_file_folder(), "SQLite_data/missing_genes.feather"),
      by = "hgnc"
    ) %>%
      dplyr::mutate(
        description = ifelse(is.na(description.x), description.y, description.x),
        entrez = ifelse(is.na(entrez.x), entrez.y, entrez.x)
      ) %>%
      dplyr::select(-c("description.x", "description.y", "entrez.y", "entrez.x"))

    cat_genes_status("Add the entrez to the genes.")
    genes <- genes %>%
      dplyr::left_join(iatlas.data::get_gene_ids(), by = "hgnc") %>%
      tibble::add_column(entrez = NA %>% as.numeric, .before = "hgnc") %>%
      dplyr::mutate(entrez = ifelse(is.na(entrez.x), entrez.y, entrez.x) %>% as.numeric) %>%
      dplyr::select(-c(entrez.x, entrez.y))

    cat_genes_status("Replace any alias hgncs, with official hgncs.")
    genes <- iatlas.data::resolve_hgnc_conflicts(genes)

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
