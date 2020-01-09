gene_ids <- feather::read_feather("../feather_files/gene_ids.feather") %>%
  dplyr::as_tibble()

node_names <- feather::read_feather("../feather_files/network_node_label_friendly.feather") %>%
  dplyr::as_tibble()

node_names <- node_names %>%
  dplyr::rename_at("Type", ~("super_category")) %>%
  dplyr::rename_at("Obj", ~("hgnc")) %>%
  dplyr::rename_at("FriendlyName", ~("display")) %>%
  tibble::add_column(type_name = "extra_cellular_network")

node_names <- node_names %>% dplyr::inner_join(gene_ids, by = "hgnc")

node_names %>% feather::write_feather("../feather_files/genes/ecn_genes.feather")

### Clean up ###
# Data
rm(gene_ids)
rm(node_names)

cat("Cleaned up.", fill = TRUE)
gc()
