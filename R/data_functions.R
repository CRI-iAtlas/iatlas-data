present <- function (a) {!is.null(a) && !(typeof(a) == "logical" && is.na(a))}

timed <- function(v, before_message = NA, after_message = "", message = NA) {
  if (present(message)) {
    before_message <- paste0(message, "...\n")
    after_message <- message
  }
  tictoc::tic(after_message)
  if (present(before_message)) cat(before_message)
  on.exit(tictoc::toc())
  v
}

build_references <- function(reference) {
  return(ifelse(
    !identical(reference, "NA") & !is.na(reference),
    paste0("{", reference %>% base::strsplit("\\s\\|\\s") %>% stringi::stri_join_list(sep = ','), "}"),
    NA
  ))
}

read_feather_with_info <- function(file_path) {
  size <- file.info(file_path)$size
  if (size > 1024**2)
    timed(feather::read_feather(file_path), before_message = paste0("READ: ", file_path, " (", floor(10 * size / 1024**2)/10, " megabytes)"))
  else
    feather::read_feather(file_path)
}

read_iatlas_data_file <- function(root_path, relative_path) {
  file_path <- paste0(root_path, "/", relative_path)
  if (grepl("[*?]",file_path)) {
    load_feather_files(Sys.glob(file_path))
  } else {
    if (!file.exists(file_path)) {
      stop(paste0("read_iatlas_data_file: file does not exist: ", file_path))
    }
    if (file.info(file_path)$isdir) {
      load_feather_data(file_path)
    } else {
      read_feather_with_info(file_path)
    }
  }
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

get_mutation_code <- function(value) {
  code <- value %>% stringi::stri_extract_first(regex = "(?=\\s) (.*)") %>% trimws()
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
load_feather_data <- function(folder = "data/test")
  load_feather_files(Sys.glob(paste0(folder, "/*.feather")))

load_feather_files <- function(file_names) {
  df <- dplyr::tibble()

  for (index in 1:length(file_names)) {
    df <- df %>%
      dplyr::bind_rows(read_feather_with_info(file_names[[index]]) %>% dplyr::as_tibble())
  }

  df
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

flatten_dupes <- function(group, field) {
  values <- group[[field]]
  valid_values <- get_unique_valid_values(group[[field]])
  if (length(valid_values) > 1) {
    print(list(group = group, field = field, valid_values = valid_values))
    stop("DIRTY DATA! Found multiple values for ", field, ": ", paste(valid_values, collapse = ", "))
  } else if (length(valid_values) == 0) {
    NA
  } else {
    valid_values[[1]]
  }
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
      present(sample_id) &&
      present(gene_id) &&
      present(col_num <- sample_map[[sample_id]]) &&
      present(row_num <- gene_map[[gene_id]])
    )
      return(gene_exp[[col_num]][[row_num]])
    return(NA)
  }
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