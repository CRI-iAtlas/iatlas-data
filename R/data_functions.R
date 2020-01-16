filter_na <- function(value = NA %>% as.character) {
  value <- unique(value)
  if (length(value) > 1 & anyNA(value)) {
    value <- na.omit(value)

    # test if there are any rows at all
    if (length(which(!is.na(value))) == 0) {
      value <- NA %>% as.character
    }
  }
  value <- ifelse(is.na(value), NA %>% as.character, max(unique(value)))
  return(value)
}

get_tag_column_names <- function(df) {
  if (!is_df_empty(df)) {
    column_names <- df %>% names()
    tag_column_names <- column_names %>%
      stringi::stri_extract_first(regex = "^tag(\\.[\\w]{1,})?") %>%
      na.omit()
    return(tag_column_names)
  }
  return(NA)
}

is_df_empty <- function(df = data.frame()) {
  if (!identical(class(df), "data.frame") & !tibble::is_tibble(df)) {
    df <- data.frame()
  }
  return(is.null(dim(df)) | dim(df)[1] == 0 | dim(df)[2] == 0)
}

link_to_references <- function(current_link) {
  if (!is.na(current_link)) {
    url <- current_link  %>% stringi::stri_extract_first(regex = "(?<=href=\").*?(?=\")")
    if (!identical(url, "NA") & !is.na(url)) {
      return(paste("{", url, "}", sep = ""))
    }
  }
  return(NA)
}

driver_results_label_to_hgnc <- function(label) {
  hgnc <- label %>% stringi::stri_extract_first(regex = "^[\\w\\s\\(\\)\\*\\-_\\?\\=]{1,}(?!=;)")
  return(if(!identical(hgnc, "NA") & !is.na(hgnc)) {hgnc} else {NA})
}

# load_feather_data:
#   Loads all feather files in a directory, concatinates them togther
#   and retruns tibble.
load_feather_data <- function(folder = "data/test") {
  # Identify all files with feather extension.
  files <- list.files(folder, pattern = "*.feather")
  files <- sprintf(paste0(folder, "/%s"), files)

  df <- dplyr::tibble()

  for (index in 1:length(files)) {
    df <- df %>% dplyr::bind_rows(feather::read_feather(files[[index]]) %>% dplyr::as_tibble())
  }

  return(df)
}

rebuild_gene_relational_data <- function(all_genes, ref_name, field_name = "name") {
  relational_data <- all_genes %>%
    dplyr::select(ref_name) %>%
    dplyr::distinct() %>%
    dplyr::filter(!is.na(!!rlang::sym(ref_name))) %>%
    dplyr::rename_at(ref_name, ~(field_name)) %>%
    dplyr::arrange(!!rlang::sym(field_name))
  return(relational_data)
}

switch_value <- function(current_row, reference_name, field_name, tibble_object = dplyr::tibble()) {
  reference_value <- current_row[[reference_name]]
  current_value <- current_row[[field_name]]
  current_reference_row <- tibble_object %>%
    dplyr::filter(!!rlang::sym(reference_name) == reference_value)
  if (!is_df_empty(current_reference_row)) {
    return(current_reference_row[[field_name]])
  } else if (!is.na(current_value)) {
    return(current_value)
  } else {
    return(NA)
  }
}
