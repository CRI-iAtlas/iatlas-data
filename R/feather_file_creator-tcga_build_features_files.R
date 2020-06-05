tcga_build_features_files <- function() {

  cat_features_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_features <- function() {
    create_global_synapse_connection()
    cat(crayon::magenta(paste0("Get features")), fill = TRUE)

    methods <- "syn22130608" %>%
      .GlobalEnv$synapse$get() %>%
      purrr::pluck("path") %>%
      feather::read_feather(.) %>%
      dplyr::select("origin" = "Feature Origin", "method_tag" = "Methods Tag") %>%
      tidyr::drop_na()


    features_old <- "feather_files/features" %>%
      list.files(full.names = T, pattern = "^features") %>%
      purrr::map(feather::read_feather) %>%
      dplyr::bind_rows() %>%
      dplyr::arrange(name)

    features <- "syn22128265" %>%
      .GlobalEnv$synapse$get() %>%
      purrr::pluck("path") %>%
      feather::read_feather(.) %>%
      dplyr::filter(VariableType == "Numeric", !is.na(FriendlyLabel)) %>%
      dplyr::select(
        "name" = "FeatureMatrixLabelTSV",
        "display" = "FriendlyLabel",
        "class" = "Variable Class",
        "order" = "Variable Class Order",
        "unit" = "Unit",
        "origin" = "Origin"
      ) %>%
      dplyr::mutate(
        "name" = stringr::str_replace_all(name, "[\\.]", "_"),
        class = dplyr::if_else(is.na(class), "Miscellaneous", class),
        class = dplyr::if_else(display %in% c("OS", "PFI"), "Survival Status", class),
        class = dplyr::if_else(display %in% c("OS Time", "PFI Time"), "Survival Time", class)
      ) %>%
      dplyr::left_join(methods, by = "origin") %>%
      dplyr::select(
        "name", "display", "class", "method_tag", "order", "unit"
      ) %>%
      dplyr::add_row(
        "name" = "Tumor_fraction",
        "display" = "Tumor Fraction",
        "class" = "Overall Proportion",
        "order" = 4,
        "unit"  = "Fraction"
      ) %>%
      dplyr::add_row(
        "name" = "totTCR_reads",
        "display" = "Total TCR reads",
        "class" = "Miscellaneous",
        "method_tag" = "TCR"
      ) %>%
      dplyr::filter(
        !(
          name == "til_percentage" &
          display == "TIL Regional Fraction (Percent)" &
          class == "Overall Proportion"
        )
      ) %>%
      dplyr::arrange(name)

    return(features)
  }

  .GlobalEnv$features <- iatlas.data::synapse_store_feather_file(
    get_features(),
    "features.feather",
    "syn22125617"
  )

  ### Clean up ###
  # Data
  rm(features, pos = ".GlobalEnv")
  cat("Cleaned up.", fill = TRUE)
  gc()
}
