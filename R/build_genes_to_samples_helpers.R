
get_result_cache <- function () {
  if (!present(.GlobalEnv$result_cache))
    .GlobalEnv$result_cache <- new.env()
  .GlobalEnv$result_cache
}

result_cached <- function (key, value) {
  result_cache <- get_result_cache()
  if (present(result_cache[[key]])) result_cache[[key]]
  else result_cache[[key]] <- value
}

reset_results_cache <- function () {
  if (present(.GlobalEnv$result_cache)) {
    rm(result_cache, pos = .GlobalEnv)
  }
  gc()
}

set_feather_file_folder <- function(feather_file_folder) .GlobalEnv$feather_file_folder <- feather_file_folder
get_feather_file_folder <- function() .GlobalEnv$feather_file_folder

get_genes <- function() result_cached("genes", iatlas.data::read_table("genes") %>% dplyr::as_tibble() %>% dplyr::select(gene_id = id, entrez, hgnc))
get_rna_seq_expr_matrix <- function() result_cached("rna_seq_expr_matrix", load_rna_seq_expr(.GlobalEnv$feather_file_folder, get_genes()))
get_all_samples <- function() result_cached("all_samples", load_all_samples())
get_patients <- function() result_cached("patients", iatlas.data::read_table("patients") %>% dplyr::select(patient_id = id, barcode))
get_all_samples_with_patient_ids <- function() result_cached("all_samples_with_patient_ids", get_all_samples() %>% dplyr::left_join(get_patients(), by = "sample"))
get_samples <- function() result_cached("samples", iatlas.data::read_table("samples") %>% dplyr::as_tibble())
