load_rna_seq_expr <- function(feather_file_folder, genes) {
  timed(
    before_message = crayon::magenta("Importing HUGE RNA Seq Expr file.\n(This is VERY large and may take some time to open. Please be patient.)\n"),
    after_message = crayon::blue("Imported HUGE RNA Seq Expr file."),
    iatlas.data::read_iatlas_data_file(feather_file_folder, "EBPlusPlusAdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.feather") %>%
      dplyr::as_tibble() %>%
      tidyr::separate(gene_id, c("hugo", "entrez"), sep = "[|]") %>%
      dplyr::select(-c(entrez)) %>%
      dplyr::filter(hugo != "?") %>%
      dplyr::filter(hugo %in% genes[["hgnc"]])
  )
}