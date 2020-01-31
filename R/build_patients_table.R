
build_patients_table <- function(feather_file_folder, all_samples, rna_seq_expr_matrix) {
  cat(crayon::magenta("Building patients data.)"), fill = TRUE)

  fmx <- read_iatlas_data_file(feather_file_folder, "fmx_df.feather") %>%
    dplyr::distinct(
      barcode = ParticipantBarcode,
      age = age_at_initial_pathologic_diagnosis,
      ethnicity,
      gender,
      height,
      race,
      weight
    )

  # Capture all the barcodes (column names). Removing the fist column "hugo".
  barcodes <- rna_seq_expr_matrix %>% names() %>% .[-1]

  # Capture all the patient barcodes (first 12 characters) ie "TCGA-OR-A5J1"
  patient_barcodes <- barcodes %>% stringi::stri_sub(to = 12L)

  # Add all patient barcodes.
  patients <- dplyr::tibble(barcode = patient_barcodes) %>% dplyr::distinct(barcode)

  # Add ages, ethnicities, genders, heights, races, and weights.
  patients <- patients %>% dplyr::left_join(fmx, by = "barcode") %>%
    dplyr::distinct(barcode, .keep_all = TRUE)

  patients <- patients %>%
    dplyr::bind_rows(all_samples %>% dplyr::distinct(barcode = sample)) %>%
    dplyr::distinct(barcode, .keep_all = TRUE)
  cat(crayon::blue("Built patients data."), fill = TRUE)

  # patients table ---------------------------------------------------
  cat(crayon::magenta("Building patients table."), fill = TRUE, sep = " ")
  patients %>% iatlas.data::replace_table("patients")
  cat(crayon::blue("Built patients table. (", nrow(patients), "rows )"), fill = TRUE, sep = " ")
}