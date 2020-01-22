build_references <- function(reference) {
  return(ifelse(
    !identical(reference, "NA") & !is.na(reference),
    paste0("{", reference %>% base::strsplit("\\s\\|\\s") %>% stringi::stri_join_list(sep = ','), "}"),
    NA
  ))
}

driver_results_label_to_hgnc <- function(label) {
  hgnc <- label %>% stringi::stri_extract_first(regex = "^[\\w\\s\\(\\)\\*\\-_\\?\\=]{1,}(?!=;)")
  if (!identical(hgnc, "NA") & !is.na(hgnc)) {hgnc} else {NA}
}

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

get_mutation_code <- function(value) {
  code <- value %>% stringi::stri_extract_first(regex = "(?=\\s) (.*)")
  return(ifelse(length(code) > 0 & !identical(code, "NA") & !is.na(code), code, NA))
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

#' get_unique_valid_values
#'
#' Takes a list and returns a new list with all NA values and all duplicate values removed
#'
#' @param values is a list
#' @return unique, non-na values
get_unique_valid_values <- function(values) {
  unique(values[!is.na(values)])
}

is_df_empty <- function(df = data.frame()) {
  if (!identical(class(df), "data.frame") & !tibble::is_tibble(df)) {
    df <- data.frame()
  }
  return(is.null(dim(df)) | dim(df)[1] == 0 | dim(df)[2] == 0)
}

link_to_references <- function(link) {
  return(ifelse(
    !is.na(link),
    build_references(link %>% stringi::stri_extract_first(regex = "(?<=href=\").*?(?=\")")),
    NA
  ))
}

#' load_feather_data:
#'
#' Loads all feather files in a directory, concatinates them togther
#' and retruns tibble.
#'
#' @param folder the path to the folder that contains the feather files to load.
#' @return A single data frame (as tibble) with all feather filke data bound together.
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

print_dupe_info <- function(group = NA, info = c()) {
  for (field in info) {
    print(paste(field,":",group[[field]]))
  }
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
    # if (!is.na(current_value)) {
    #   stop(paste0("Expected only one of the two records to have a value in field: ", field_name))
    # }
    return(current_reference_row[[field_name]])
  } else if (!is.na(current_value)) {
    return(current_value)
  } else {
    return(NA)
  }
}

trim_hgnc <- function(hgnc) {
  hgnc <- hgnc %>% stringi::stri_extract_first(regex = "([^\\s]+)")
  return(ifelse(length(hgnc) > 0 & !identical(hgnc, "NA") & !is.na(hgnc), hgnc, NA))
}

#' Validate duplicates
#'
#' Ensures that there is no conflicting data in the group before sumarising
#'
#' @param through_put information that gets piped to next function if no conflicts found.
#' @param group .data pronoun containing info about the current group
#' @param fields vector that contains the fields where to look for duplicates/conflicts
#' @param info extra fields printed to provide more context when a conflict is found.
#' @return pass_through or stops if conflict is found.
#'
validate_dupes <- function(pass_through, group = NA, fields = c(), info = c()) {
  for (field in fields) {
    valid_values <- get_unique_valid_values(group[[field]])
    if (length(valid_values) > 1) {
      print_dupe_info(group,info)
      stop("DIRTY DATA! Found multiple values for ", field, ": ", paste(valid_values, collapse = ", "))
    }
  }
  return(pass_through)
}
