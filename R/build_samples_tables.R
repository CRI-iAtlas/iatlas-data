build_samples_tables <- function(feather_file_folder) {
  apply_path <- function(sub_path) {
    paste0(feather_file_folder, "/", sub_path)
  }

  iatlas.data::drop_table("features_to_samples")
  iatlas.data::drop_table("genes_to_samples")
  iatlas.data::drop_table("patients_to_slides")
  iatlas.data::drop_table("samples_to_tags")
  iatlas.data::delete_rows("patients")
  iatlas.data::delete_rows("samples")
  iatlas.data::delete_rows("slides")

  cat(crayon::magenta("Importing HUGE RNA Seq Expr file.\n(This is VERY large and will take some time to open. Please be patient.)"), fill = TRUE)
  # rna_seq_exprs <- read.table(file=paste0(getwd(), "/tsv_files/EBPlusPlusAdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.tsv"), sep = "\t", header = TRUE, check.names = TRUE) %>% dplyr::as_tibble()
  rna_seq_exprs <- feather::read_feather(apply_path("EBPlusPlusAdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.feather")) %>% dplyr::as_tibble()
  barcodes <- rna_seq_exprs %>% names()
  patient_barcodes <- barcodes %>% stringi::stri_sub(to = 12L)
  sample_codes <- barcodes %>% stringi::stri_sub(to = 15L)
  # patient_barcodes[1] <- "gene"
  # names(rna_seq_exprs) <- patient_barcodes
  cat(crayon::blue("Imported HUGE RNA Seq Expr file."), fill = TRUE)

  cat(crayon::magenta("Building patients data.)"), fill = TRUE)
  fmx <- feather::read_feather(apply_path("original_data/fmx_df.feather")) %>%
    dplyr::distinct(
      barcode = ParticipantBarcode,
      age = age_at_initial_pathologic_diagnosis,
      ethnicity,
      gender,
      height,
      race,
      weight
    )
  # Add all patient barcodes.
  patients <- dplyr::tibble(barcode = patient_barcodes) %>% dplyr::distinct(barcode)
  # Add ages, ethnicities, genders, heights, races, and weights.
  patients <- patients %>% dplyr::left_join(fmx, by = "barcode")
  cat(crayon::blue("Built patients data."), fill = TRUE)

  cat(crayon::magenta("Building patients table."), fill = TRUE, sep = " ")
  table_written <- patients %>% iatlas.data::write_table_ts("patients")
  cat(crayon::blue("Built patients table. (", nrow(patients), "rows )"), fill = TRUE, sep = " ")

  rm(fmx)
  cat("Cleaned up.", fill = TRUE)
  gc()

  cat(crayon::magenta("Importing the Representative_Expression_Matrix_AliquotBarcode data and the til_image_link data."), fill = TRUE)
  expr_matrix <- feather::read_feather(apply_path("Representative_Expression_Matrix_AliquotBarcode.feather"))
  til_image_links <- feather::read_feather(apply_path("SQLite_data/til_image_links.feather"))
  cat(crayon::blue("Imported the Representative_Expression_Matrix_AliquotBarcode data and the til_image_link data."), fill = TRUE)

  # Combine all the sample data. Include the feature_values_long dataframe but
  # ensure its "value" field (from feature_values_long) remains distinct from
  # the "value" field renamed to "rna_seq_expr".
  cat(crayon::magenta("Importing feather files for samples and combining all the sample data."), fill = TRUE)
  feature_values_long <- feather::read_feather(apply_path("SQLite_data/feature_values_long.feather"))
  all_samples <- dplyr::bind_rows(
      feather::read_feather(apply_path("SQLite_data/driver_mutations1.feather")),
      feather::read_feather(apply_path("SQLite_data/driver_mutations2.feather")),
      feather::read_feather(apply_path("SQLite_data/driver_mutations3.feather")),
      feather::read_feather(apply_path("SQLite_data/driver_mutations4.feather")),
      feather::read_feather(apply_path("SQLite_data/driver_mutations5.feather")),
      feather::read_feather(apply_path("SQLite_data/io_target_expr1.feather")),
      feather::read_feather(apply_path("SQLite_data/io_target_expr2.feather")),
      feather::read_feather(apply_path("SQLite_data/io_target_expr3.feather")),
      feather::read_feather(apply_path("SQLite_data/io_target_expr4.feather")),
      feather::read_feather(apply_path("SQLite_data/immunomodulator_expr.feather"))
    ) %>%
    dplyr::rename(rna_seq_expr = value) %>%
    dplyr::bind_rows(feature_values_long) %>%
    dplyr::arrange(sample)
  all_samples <- all_samples %>%
    dplyr::left_join(expr_matrix, by = c("sample" = "ParticipantBarcode")) %>%
    dplyr::rename(barcode = Representative_Expression_Matrix_AliquotBarcode)
  patients <- iatlas.data::read_table("patients") %>%
    dplyr::select(id, barcode) %>%
    dplyr::rename(patient_id = id) %>%
    dplyr::rename(sample = barcode)
  all_samples <- all_samples %>% dplyr::left_join(patients, by = "sample")
  cat(crayon::blue("Imported feather files for samples and combined all the sample data."), fill = TRUE)

  # Clean up.
  rm(feature_values_long)
  cat("Cleaned up.", fill = TRUE)
  gc()

  # Build the samples table.
  # Get only the sample names (no duplicates).
  cat(crayon::magenta("Building samples data."), fill = TRUE)
  samples <- all_samples %>%
    dplyr::distinct(sample, patient_id) %>%
    dplyr::rename(name = sample) %>%
    dplyr::arrange(name)
  cat(crayon::blue("Built samples data."), fill = TRUE)

  cat(crayon::magenta("Building the samples table."), fill = TRUE)
  table_written <- samples %>% iatlas.data::write_table_ts("samples")
  samples <- iatlas.data::read_table("samples") %>% dplyr::as_tibble()
  cat(crayon::blue("Built the samples table. (", nrow(samples), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building slides data."), fill = TRUE)
  slides <- til_image_links %>%
    dplyr::rename(name = link) %>%
    dplyr::mutate(name = ifelse(!is.na(name), stringi::stri_extract_first(name, regex = "[\\w]{4}-[\\w]{2}-[\\w]{4}-[\\w]{3}-[\\d]{2}-[\\w]{3}"), NA)) %>%
    dplyr::distinct(name, .keep_all = TRUE)
  cat(crayon::blue("Built slides data."), fill = TRUE)

  cat(crayon::magenta("Building the slides table."), fill = TRUE)
  table_written <- slides %>% dplyr::distinct(name) %>% iatlas.data::write_table_ts("slides")
  cat(crayon::blue("Built the slides table. (", nrow(slides), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building patients_to_slides data."), fill = TRUE)
  patients_to_slides <- slides %>%
    dplyr::left_join(
      iatlas.data::read_table("slides") %>%
        dplyr::select(slide_id = id, name),
      by = "name"
    )
  patients_to_slides <- patients_to_slides %>%
    dplyr::left_join(patients, by = "sample") %>%
    dplyr::filter(!is.na(patient_id)) %>%
    dplyr::distinct(patient_id, slide_id) %>%
    dplyr::arrange(patient_id, slide_id)
  cat(crayon::blue("Built patients_to_slides data."), fill = TRUE)

  cat(crayon::magenta("Building the patients_to_slides table."), fill = TRUE)
  table_written <- patients_to_slides %>% iatlas.data::write_table_ts("patients_to_slides")
  cat(crayon::blue("Built the patients_to_slides table. (", nrow(patients_to_slides), "rows )"), fill = TRUE, sep = " ")

  # Remove the large til_image_links as we are done with it.
  rm(til_image_links)
  cat("Cleaned up.", fill = TRUE)
  gc()

  cat(crayon::magenta("Building samples_to_tags data."), fill = TRUE)
  tags <- iatlas.data::read_table("tags") %>%
    dplyr::as_tibble() %>%
    dplyr::select(id, name)
  sample_set_tcga_study <- all_samples %>%
    dplyr::distinct(sample, TCGA_Study) %>%
    dplyr::inner_join(tags, by = c("TCGA_Study" = "name")) %>%
    dplyr::rename(tag_id = id) %>%
    dplyr::distinct(sample, tag_id)
  sample_set_tcga_subtype <- all_samples %>%
    dplyr::distinct(sample, TCGA_Subtype) %>%
    dplyr::inner_join(tags, by = c("TCGA_Subtype" = "name")) %>%
    dplyr::rename(tag_id = id) %>%
    dplyr::distinct(sample, tag_id)
  sample_set_immune_subtype <- all_samples %>%
    dplyr::distinct(sample, Immune_Subtype) %>%
    dplyr::inner_join(tags, by = c("Immune_Subtype" = "name")) %>%
    dplyr::rename(tag_id = id) %>%
    dplyr::distinct(sample, tag_id)
  samples_to_tags <- sample_set_tcga_study %>%
    dplyr::bind_rows(sample_set_tcga_subtype, sample_set_immune_subtype) %>%
    dplyr::inner_join(samples, by = c("sample" = "name")) %>%
    dplyr::distinct(id, tag_id) %>%
    dplyr::rename(sample_id = id)
  cat(crayon::blue("Built samples_to_tags data."), fill = TRUE)

  rm(sample_set_tcga_study)
  rm(sample_set_tcga_subtype)
  rm(sample_set_immune_subtype)
  rm(tags)
  cat("Cleaned up.", fill = TRUE)
  gc()

  cat(crayon::magenta("Building samples_to_tags table."), fill = TRUE)
  samples_to_tags %>% iatlas.data::replace_table("samples_to_tags")
  cat(crayon::blue("Built samples_to_tags table. (", nrow(samples_to_tags), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building samples_to_features data."), fill = TRUE)
  features <- iatlas.data::read_table("features") %>%
    dplyr::as_tibble() %>%
    dplyr::select(id, name)
  sample_set_features <- all_samples %>%
    dplyr::distinct(sample, feature, value) %>%
    dplyr::inner_join(features, by = c("feature" = "name")) %>%
    dplyr::rename(feature_id = id) %>%
    dplyr::distinct(sample, feature_id, value)
  features_to_samples <- sample_set_features %>%
    dplyr::inner_join(samples, by = c("sample" = "name")) %>%
    dplyr::distinct(id, feature_id, value) %>%
    dplyr::rename(sample_id = id) %>%
    dplyr::mutate(inf_value = ifelse(is.infinite(value), value, NA), value = ifelse(is.finite(value), value, NA))
  cat(crayon::blue("Built samples_to_features data."), fill = TRUE)

  rm(sample_set_features)
  rm(features)
  cat("Cleaned up.", fill = TRUE)
  gc()

  cat(crayon::magenta("Building features_to_samples table.\n(Please be patient, this may take a little while as there are", nrow(features_to_samples), "rows to write.)"), fill = TRUE, sep = " ")
  features_to_samples %>% iatlas.data::replace_table("features_to_samples")
  cat(crayon::blue("Built features_to_samples table. (", nrow(features_to_samples), "rows )"), fill = TRUE, sep = " ")

  cat(crayon::magenta("Building genes_to_samples data.\n(These are some large datasets, please be patient as they are read and built.)"), fill = TRUE)
  genes <- iatlas.data::read_table("genes") %>% dplyr::as_tibble() %>% dplyr::select(id, hgnc)
  mutation_codes <- iatlas.data::read_table("mutation_codes") %>% dplyr::as_tibble()
  genes_to_samples <- all_samples %>% dplyr::distinct(sample, gene, status, rna_seq_expr, barcode)
  genes_to_samples <- genes_to_samples %>%
    dplyr::mutate(
      code = ifelse(!is.na(gene), iatlas.data::get_mutation_code(gene), NA),
      hgnc = ifelse(!is.na(gene), iatlas.data::trim_hgnc(gene), NA)
    )
  genes_to_samples <- genes_to_samples %>%
    dplyr::mutate(
      rna_seq_expr = ifelse(
        !is.na(hgnc) & !is.na(sample) & deparse(substitute(sample)) %in% patient_barcodes,
        rna_seq_exprs[sample] %>% dplyr::filter(grepl(paste0(hgnc, "\\|"), gene)),
        ifelse(!is.na(rna_seq_expr), rna_seq_expr, NA)
      )
    )
  genes_to_samples <- genes_to_samples %>%
    dplyr::distinct(sample, hgnc, code, status, rna_seq_expr)
  genes_to_samples <- genes_to_samples %>%
    dplyr::left_join(genes %>% dplyr::rename(gene_id = id), by = "hgnc")
  genes_to_samples <- genes_to_samples %>%
    dplyr::left_join(mutation_codes %>% dplyr::rename(mutation_code_id = id), by = "code")
  genes_to_samples <- genes_to_samples %>%
    dplyr::distinct(sample, gene_id, mutation_code_id, status, rna_seq_expr)
  genes_to_samples <- genes_to_samples %>%
    dplyr::left_join(samples, by = c("sample" = "name"))
  genes_to_samples <- genes_to_samples %>%
    dplyr::distinct(id, gene_id, mutation_code_id, status, rna_seq_expr)
  genes_to_samples <- genes_to_samples %>%
    dplyr::rename(sample_id = id) %>%
    dplyr::arrange(sample_id, gene_id, mutation_code_id, status, rna_seq_expr)
  genes_to_samples <- genes_to_samples %>%
    dplyr::group_by(sample_id, gene_id, mutation_code_id) %>%
    dplyr::summarise(
      status = iatlas.data::validate_dupes(status, group = .data, fields = c("status"), info = c("gene_id", "sample_id", "mutation_code_id")) %>% iatlas.data::filter_na(),
      rna_seq_expr = iatlas.data::validate_dupes(rna_seq_expr, group = .data, fields = c("rna_seq_expr"), info = c("gene_id", "sample_id", "mutation_code_id")) %>% iatlas.data::filter_na() %>% as.numeric()
    )
  cat(crayon::blue("Built genes_to_samples data."), fill = TRUE)

  cat(crayon::magenta("Building genes_to_samples table.\n(There are", nrow(genes_to_samples), "rows to write, this may take a little while.)"), fill = TRUE)
  genes_to_samples %>% iatlas.data::replace_table("genes_to_samples")
  cat(crayon::blue("Built genes_to_samples table. (", nrow(genes_to_samples), "rows )"), fill = TRUE, sep = " ")
}
