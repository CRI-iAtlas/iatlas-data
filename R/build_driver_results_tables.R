.GlobalEnv$delete_rows("driver_results")

cat(crayon::magenta("Importing feather files for results."), fill = TRUE)
driver_results1 <- feather::read_feather("../feather_files/SQLite_data/driver_results1.feather")
driver_results2 <- feather::read_feather("../feather_files/SQLite_data/driver_results2.feather")
cat(crayon::blue("Imported feather files for results."), fill = TRUE)

cat(crayon::magenta("Bind driver_results data frames."), fill = TRUE)
all_results <- dplyr::bind_rows(driver_results1, driver_results2) %>% dplyr::as_tibble()
cat(crayon::blue("Bound driver_results data frames."), fill = TRUE)

# Clean up.
rm(driver_results1)
rm(driver_results2)
cat("Cleaned up.", fill = TRUE)
gc()

cat(crayon::magenta("Building driver_results data."), fill = TRUE)
features <- .GlobalEnv$read_table("features") %>%
  dplyr::as_tibble() %>%
  dplyr::select(id, name) %>%
  dplyr::rename_at("id", ~("feature_id"))
genes <- .GlobalEnv$read_table("genes") %>%
  dplyr::as_tibble() %>%
  dplyr::select(id, hgnc) %>%
  dplyr::rename_at("id", ~("gene_id"))
tags <- .GlobalEnv$read_table("tags") %>%
  dplyr::as_tibble() %>%
  dplyr::select(id, name) %>%
  dplyr::rename_at("id", ~("tag_id"))
results <- all_results %>%
  dplyr::mutate(hgnc = ifelse(!is.na(label), .GlobalEnv$driver_results_label_to_hgnc(label), NA)) %>%
  dplyr::rename_at("pvalue", ~("p_value")) %>%
  dplyr::rename_at("log10_pvalue", ~("log10_p_value")) %>%
  dplyr::mutate(hgnc = .GlobalEnv$driver_results_label_to_hgnc(label)) %>%
  dplyr::inner_join(features, by = c("feature" = "name")) %>%
  dplyr::inner_join(genes, by = "hgnc") %>%
  dplyr::inner_join(tags, by = c("group" = "name")) %>%
  dplyr::select(-c("feature", "group", "hgnc", "label", "parent_group"))
cat(crayon::blue("Built driver_results data."), fill = TRUE)

cat(crayon::magenta("Building driver_results table.\n(Please be patient, this may take a little while as there are", nrow(results), "rows to write.)"), fill = TRUE, spe = " ")
table_written <- results %>% .GlobalEnv$write_table_ts("driver_results")
cat(crayon::blue("Built driver_results table. (", nrow(results), "rows )"), fill = TRUE, sep = " ")

# Remove the data we are done with.
rm(all_results)
rm(features)
rm(genes)
rm(results)
rm(table_written)
rm(tags)
cat("Cleaned up.", fill = TRUE)
gc()
