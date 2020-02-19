build_references <- function(reference) {
  return(ifelse(
    reference != "NA" & !is.na(reference),
    paste0("{", reference %>% base::strsplit("\\s\\|\\s") %>% stringi::stri_join_list(sep = ','), "}"),
    NA
  ))
}

driver_results_label_to_hgnc <- function(label) {
  hgnc <- label %>% stringi::stri_extract_first(regex = "^[\\w\\s\\(\\)\\*\\-_\\?\\=]{1,}(?!=;)")
  return(ifelse(
    !identical(hgnc, "NA") & !is.na(hgnc),
    hgnc,
    NA
  ))
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

#` returns new record_ids_to_tags with all tags flattened
#`
#` @param record_ids_to_tags: tibble with tag_id and related_tag_id columns
#` @param tags_to_tags: tibble with tag_id and related_tag_id columns
#`
#` @return same format as record_ids_to_tags, only flattened
flatten_tags <- function (record_ids_to_tags, tags_to_tags, record_id_field = "id") {
  records <- record_ids_to_tags %>% dplyr::rename(record_id = record_id_field)
  flatten_once <- function(recs) {
    recs %>%
      dplyr::left_join(tags_to_tags, by="tag_id") %>%
      dplyr::select(record_id, tag_id = related_tag_id) %>%
      dplyr::filter(!is.na(tag_id)) %>%
      dplyr::bind_rows(recs) %>%
      dplyr::distinct(record_id, tag_id)
  }
  count_down <- 20
  while (nrow(records) < nrow(new_recs <- flatten_once(records))) {
    records <- new_recs
    count_down <- count_down - 1
    if (count_down <= 0) stop("max depth reached flattening tags - do you have circular tags in tags_to_tags?")
  }
  records %>% dplyr::rename(!!record_id_field := record_id)
}

get_mutation_code <- function(value) {
  code <- value %>% stringi::stri_extract_first(regex = "(?=\\s) (.*)") %>% trimws()
  return(ifelse(length(code) > 0 & !identical(code, "NA") & !is.na(code), code, NA))
}

link_to_references <- function(link) {
  return(ifelse(
    !is.na(link),
    build_references(link %>% stringi::stri_extract_first(regex = "(?<=href=\").*?(?=\")")),
    NA
  ))
}

print_dupe_info <- function(group = NA, info = c()) {
  for (field in info) {
    print(paste(field,":",group[[field]]))
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
    valid_values <- iatlas.data::get_unique_valid_values(group[[field]])
    if (length(valid_values) > 1) {
      print_dupe_info(group,info)
      stop("DIRTY DATA! Found multiple values for ", field, ": ", paste(valid_values, collapse = ", "))
    }
  }
  return(pass_through)
}

vector_to_env <- function(vec) {
  output <- new.env()
  count <- 1
  for (v in vec) {
    output[[v]] <- count
    count <- count + 1
  }
  invisible(output)
}

#' create_gene_expression_lookup
#'
#' @param gen_exp is the large, 1.8gigabyte TCGA feather-file loaded via feather::read_feather
#' @return lookup(), a function that takes (gene_id, sample_id) and returns the gene-expression or NULL if no match
create_gene_expression_lookup <- function (gene_exp) {
  gene_exp <- tibble::as_tibble(gene_exp)
  gene_map <- vector_to_env(purrr::map(gene_exp[[1]], function(f) strsplit(f, "\\|")[[1]][[1]]))
  sample_map <- vector_to_env(colnames(gene_exp))

  function(gene_id, sample_id) {
    if (
      iatlas.data::present(sample_id) &&
      iatlas.data::present(gene_id) &&
      iatlas.data::present(col_num <- sample_map[[sample_id]]) &&
      iatlas.data::present(row_num <- gene_map[[gene_id]])
    )
      return(gene_exp[[col_num]][[row_num]])
    return(NA)
  }
}
