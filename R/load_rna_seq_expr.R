load_rna_seq_expr <- function(feather_file_folder, genes) {
  iatlas.data::timed(
    before_message = crayon::magenta("Importing HUGE RNA Seq Expr file.\n(This is VERY large and may take some time to open. Please be patient.)\n"),
    after_message = crayon::blue("Imported HUGE RNA Seq Expr file."),

    get_rna_seq_expr(feather_file_folder) %>%
      tidyr::separate(gene_id, c("hgnc", "entrez"), sep = "[|]") %>%
      dplyr::select(-c(entrez)) %>%
      dplyr::filter(hgnc != "?") %>%
      dplyr::filter(hgnc %in% genes[["hgnc"]])
  )
}

get_rna_seq_expr <- function(feather_file_folder) {
  feather_file <- paste0(feather_file_folder, "/EBPlusPlusAdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.feather")
  if (!file.exists(feather_file)) {
    cat(crayon::blue("Reading rn_seq_expr file from Synapse."), fill = TRUE)
    iatlas.data::create_global_synapse_connection()
    on.exit(iatlas.data::synapse_logout())
    return(
      "syn4976369" %>%
        .GlobalEnv$synapse$get() %>%
        .$path %>%
        read.csv(stringsAsFactors = F, header = T, sep = "\t", check.names = F) %>%
        dplyr::as_tibble() %>%
        feather::write_feather(feather_file)
    )
  }
  return(feather::read_feather(feather_file))
}
