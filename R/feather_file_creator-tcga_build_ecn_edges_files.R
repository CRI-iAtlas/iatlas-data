tcga_build_ecn_edges_files <- function() {
  # Create a global variable to hold the pool DB connection.
  .GlobalEnv$pool <- iatlas.data::connect_to_db()
  cat(crayon::green("Created DB connection."), fill = TRUE)

  cat_ecn_edges_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  apply_path <- function(sub_path) {
    paste0("feather_files/SQLite_data/edges/", sub_path)
  }

  current_pool <- pool::poolCheckout(.GlobalEnv$pool)

  genes <- current_pool %>% dplyr::tbl("genes") %>% dplyr::as_tibble() %>% dplyr::select(entrez, hgnc)

  fix_features <- function(df) {
    df %>%
      dplyr::rowwise() %>%
      dplyr::mutate(
        from = ifelse(
          identical(from, "B_cells") |
            identical(from, "Dendritic_cells") |
            identical(from, "Eosinophils") |
            identical(from, "Macrophage") |
            identical(from, "Mast_cells") |
            identical(from, "Neutrophils") |
            identical(from, "NK_cells") |
            identical(from, "T_cells_CD4") |
            identical(from, "T_cells_CD8"),
          paste0(from, ".Aggregate2"),
          from
        ),
        to = ifelse(
          identical(to, "B_cells") |
            identical(to, "Dendritic_cells") |
            identical(to, "Eosinophils") |
            identical(to, "Macrophage") |
            identical(to, "Mast_cells") |
            identical(to, "Neutrophils") |
            identical(to, "NK_cells") |
            identical(to, "T_cells_CD4") |
            identical(to, "T_cells_CD8"),
          paste0(to, ".Aggregate2"),
          to
        )
      )
  }

  hgnc_to_entrez <- function(df) {
    df <- df %>% dplyr::left_join(
      genes, by = c("from" = "hgnc")
    ) %>%
      dplyr::bind_rows(dplyr::tibble(
        entrez = numeric(),
        from = character(),
        to = character(),
        tag = character(),
        score = numeric()
      )) %>%
      dplyr::mutate(from = ifelse(!is.na(entrez), entrez %>% as.character(), from)) %>%
      dplyr::select(-c("entrez"))

    df %>% dplyr::left_join(
      genes, by = c("to" = "hgnc")
    ) %>%
      dplyr::bind_rows(dplyr::tibble(
        entrez = numeric(),
        from = character(),
        to = character(),
        tag = character(),
        score = numeric()
      )) %>%
      dplyr::mutate(to = ifelse(!is.na(entrez), entrez %>% as.character(), to)) %>%
      dplyr::select(-c("entrez"))
  }

  cat_ecn_edges_status("Creating the edges_TCGAImmune data.")
  edges_TCGAImmune <- feather::read_feather(apply_path("edges_TCGAImmune.feather")) %>%
    dplyr::distinct(from = From, to = To, tag = Group, score = ratioScore) %>%
    fix_features() %>%
    hgnc_to_entrez() %>%
    dplyr::arrange(from, to, tag)

  cat_ecn_edges_status("Creating the edges_TCGAStudy_Immune data.")
  edges_TCGAStudy_Immune <- feather::read_feather(apply_path("edges_TCGAStudy_Immune.feather")) %>%
    dplyr::distinct(from = From, to = To, tag = Group, tag.01 = Immune, score = ratioScore) %>%
    fix_features() %>%
    hgnc_to_entrez() %>%
    dplyr::arrange(from, to, tag, tag.01)

  cat_ecn_edges_status("Creating the edges_TCGAStudy data.")
  edges_TCGAStudy <- feather::read_feather(apply_path("edges_TCGAStudy.feather")) %>%
    dplyr::distinct(from = From, to = To, tag = Group, score = ratioScore) %>%
    fix_features() %>%
    hgnc_to_entrez() %>%
    dplyr::arrange(from, to, tag)

  cat_ecn_edges_status("Creating the edges_TCGASubtype data.")
  edges_TCGASubtype <- feather::read_feather(apply_path("edges_TCGASubtype.feather")) %>%
    dplyr::distinct(from = From, to = To, tag = Group, score = ratioScore) %>%
    fix_features() %>%
    hgnc_to_entrez() %>%
    dplyr::arrange(from, to, tag)

  pool::poolReturn(current_pool)

  # Close the database connection.
  pool::poolClose(.GlobalEnv$pool)
  cat(crayon::green("Closed DB connection."), fill = TRUE)

  .GlobalEnv$edges_TCGAImmune <- edges_TCGAImmune %>%
    feather::write_feather(paste0(getwd(), "/feather_files/edges/edges_TCGAImmune.feather"))

  .GlobalEnv$edges_TCGAStudy_Immune <- edges_TCGAStudy_Immune %>%
    feather::write_feather(paste0(getwd(), "/feather_files/edges/edges_TCGAStudy_Immune.feather"))

  .GlobalEnv$edges_TCGAStudy <- edges_TCGAStudy %>%
    feather::write_feather(paste0(getwd(), "/feather_files/edges/edges_TCGAStudy.feather"))

  .GlobalEnv$edges_TCGASubtype <- edges_TCGASubtype %>%
    feather::write_feather(paste0(getwd(), "/feather_files/edges/edges_TCGASubtype.feather"))

  ### Clean up ###
  # Data
  rm(pool, pos = ".GlobalEnv")
  rm(edges_TCGAImmune, pos = ".GlobalEnv")
  rm(edges_TCGAStudy_Immune, pos = ".GlobalEnv")
  rm(edges_TCGAStudy, pos = ".GlobalEnv")
  rm(edges_TCGASubtype, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
