sql_schema <- list(
  classes = list(
    create = "
      CREATE TABLE classes (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX class_name_index ON classes (\"name\");"
    )
  ),
  copy_number_results = list(
    create = "
      CREATE TABLE copy_number_results (
        id SERIAL,
        direction DIRECTION_ENUM NOT NULL,
        mean_normal NUMERIC,
        mean_cnv NUMERIC,
        p_value NUMERIC,
        log10_p_value NUMERIC,
        t_stat NUMERIC,
        feature_id INTEGER NOT NULL,
        gene_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        dataset_id INTEGER NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE INDEX copy_number_result_feature_id_index ON copy_number_results (feature_id);",
      "CREATE INDEX copy_number_result_gene_id_index ON copy_number_results (gene_id);",
      "CREATE INDEX copy_number_result_tag_id_index ON copy_number_results (tag_id);",
      "ALTER TABLE copy_number_results ADD FOREIGN KEY (feature_id) REFERENCES features;",
      "ALTER TABLE copy_number_results ADD FOREIGN KEY (gene_id) REFERENCES genes;",
      "ALTER TABLE copy_number_results ADD FOREIGN KEY (tag_id) REFERENCES tags;",
      "ALTER TABLE copy_number_results ADD FOREIGN KEY (dataset_id) REFERENCES datasets;"
    )
  ),
  datasets = list(
    create = "
      CREATE TABLE datasets (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        display VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX dataset_name_index ON datasets (\"name\");"
    )
  ),
  datasets_to_samples = list(
    create = "
      CREATE TABLE datasets_to_samples (
        dataset_id INTEGER,
        sample_id INTEGER,
        PRIMARY KEY (dataset_id, sample_id)
      );",
    addSchema = c(
      "CREATE INDEX dataset_to_sample_dataset_id_index ON datasets_to_samples (dataset_id);",
      "ALTER TABLE datasets_to_samples ADD FOREIGN KEY (dataset_id) REFERENCES datasets;",
      "ALTER TABLE datasets_to_samples ADD FOREIGN KEY (sample_id) REFERENCES samples;"
    )
  ),
  datasets_to_tags = list(
    create = "
      CREATE TABLE datasets_to_tags (
        dataset_id INTEGER,
        tag_id INTEGER,
        PRIMARY KEY (dataset_id, tag_id)
      );",
    addSchema = c(
      "CREATE INDEX dataset_to_tag_dataset_id_index ON datasets_to_tags (dataset_id);",
      "ALTER TABLE datasets_to_tags ADD FOREIGN KEY (dataset_id) REFERENCES datasets;",
      "ALTER TABLE datasets_to_tags ADD FOREIGN KEY (tag_id) REFERENCES tags;"
    )
  ),
  driver_results = list(
    create = "
      CREATE TABLE driver_results (
        id SERIAL,
        p_value NUMERIC,
        fold_change NUMERIC,
        log10_p_value NUMERIC,
        log10_fold_change NUMERIC,
        n_wt INTEGER,
        n_mut INTEGER,
        feature_id INTEGER,
        gene_id INTEGER,
        mutation_code_id INTEGER,
        tag_id INTEGER,
        dataset_id INTEGER NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE INDEX driver_result_feature_id_index ON driver_results (feature_id);",
      "CREATE INDEX driver_result_gene_id_index ON driver_results (gene_id);",
      "CREATE INDEX driver_result_tag_id_index ON driver_results (tag_id);",
      "CREATE INDEX driver_result_mutation_code_id_index ON driver_results (mutation_code_id);",
      "ALTER TABLE driver_results ADD FOREIGN KEY (feature_id) REFERENCES features;",
      "ALTER TABLE driver_results ADD FOREIGN KEY (gene_id) REFERENCES genes;",
      "ALTER TABLE driver_results ADD FOREIGN KEY (tag_id) REFERENCES tags;",
      "ALTER TABLE driver_results ADD FOREIGN KEY (mutation_code_id) REFERENCES mutation_codes;",
      "ALTER TABLE driver_results ADD FOREIGN KEY (dataset_id) REFERENCES datasets;"
    )
  ),
  edges_to_tags = list(
    create = "
      CREATE TABLE edges_to_tags (
        edge_id INTEGER,
        tag_id INTEGER,
        PRIMARY KEY (edge_id, tag_id)
      );",
    addSchema = c(
      "CREATE INDEX edge_to_tag_tag_id_index ON edges_to_tags (tag_id);",
      "ALTER TABLE edges_to_tags ADD FOREIGN KEY (edge_id) REFERENCES edges;",
      "ALTER TABLE edges_to_tags ADD FOREIGN KEY (tag_id) REFERENCES tags;"
    )
  ),
  edges = list(
    create = "
      CREATE TABLE edges (
        id SERIAL,
        name VARCHAR NOT NULL,
        label VARCHAR,
        node_1_id INTEGER NOT NULL,
        node_2_id INTEGER NOT NULL,
        score NUMERIC,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE INDEX edge_node_2_id_index ON edges (node_2_id);",
      "CREATE INDEX edge_nodes_id_index ON edges (node_1_id, node_2_id);",
      "ALTER TABLE edges ADD FOREIGN KEY (node_1_id) REFERENCES nodes;",
      "ALTER TABLE edges ADD FOREIGN KEY (node_2_id) REFERENCES nodes;"
    )
  ),
  features = list(
    create = "
      CREATE TABLE features (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        display VARCHAR,
        \"order\" INTEGER,
        unit UNIT_ENUM,
        class_id INTEGER NOT NULL,
        method_tag_id INTEGER,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX feature_name_index ON features (\"name\");",
      "CREATE INDEX feature_class_id_index ON features (class_id);",
      "CREATE INDEX feature_method_tag_id_index ON features (method_tag_id);",
      "ALTER TABLE features ADD FOREIGN KEY (class_id) REFERENCES classes;",
      "ALTER TABLE features ADD FOREIGN KEY (method_tag_id) REFERENCES method_tags;"
    )
  ),
  features_to_samples = list(
    create = "
      CREATE TABLE features_to_samples (
        feature_id INTEGER,
        sample_id INTEGER,
        \"value\" NUMERIC,
        inf_value REAL,
        PRIMARY KEY (feature_id, sample_id)
      );",
    addSchema = c(
      "CREATE INDEX feature_to_sample_sample_id_index ON features_to_samples (sample_id);",
      "ALTER TABLE features_to_samples ADD FOREIGN KEY (feature_id) REFERENCES features;",
      "ALTER TABLE features_to_samples ADD FOREIGN KEY (sample_id) REFERENCES samples;"
    )
  ),
  genes = list(
    create = "
      CREATE TABLE genes (
        id SERIAL,
        entrez INTEGER,
        hgnc VARCHAR NOT NULL,
        description VARCHAR,
        friendly_name VARCHAR,
        io_landscape_name VARCHAR,
        \"references\" TEXT[],
        gene_family_id        INTEGER REFERENCES gene_families,
        gene_function_id      INTEGER REFERENCES gene_functions,
        immune_checkpoint_id  INTEGER REFERENCES immune_checkpoints,
        pathway_id            INTEGER REFERENCES pathways,
        super_cat_id          INTEGER REFERENCES super_categories,
        therapy_type_id       INTEGER REFERENCES therapy_types,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX gene_entrez_index ON genes (entrez);",
      "CREATE INDEX gene_hgnc_index ON genes (hgnc);",
      "CREATE INDEX gene_gene_family_id_index ON genes (gene_family_id);",
      "CREATE INDEX gene_gene_function_id_index ON genes (gene_function_id);",
      "CREATE INDEX gene_immune_checkpoint_id_index ON genes (immune_checkpoint_id);",
      "CREATE INDEX gene_pathway_id_index ON genes (pathway_id);",
      "CREATE INDEX gene_super_cat_id_index ON genes (super_cat_id);",
      "CREATE INDEX gene_therapy_type_id_index ON genes (therapy_type_id);",

      "ALTER TABLE genes ADD FOREIGN KEY (gene_family_id       ) REFERENCES gene_families;",
      "ALTER TABLE genes ADD FOREIGN KEY (gene_function_id     ) REFERENCES gene_functions;",
      "ALTER TABLE genes ADD FOREIGN KEY (immune_checkpoint_id ) REFERENCES immune_checkpoints;",
      "ALTER TABLE genes ADD FOREIGN KEY (pathway_id           ) REFERENCES pathways;",
      "ALTER TABLE genes ADD FOREIGN KEY (super_cat_id         ) REFERENCES super_categories;",
      "ALTER TABLE genes ADD FOREIGN KEY (therapy_type_id      ) REFERENCES therapy_types;"
    )
  ),
  gene_families = list(
    create = "
      CREATE TABLE gene_families (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX gene_family_name_index ON gene_families (\"name\");"
    )
  ),
  gene_functions = list(
    create = "
      CREATE TABLE gene_functions (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX gene_function_name_index ON gene_functions (\"name\");"
    )
  ),
  gene_types = list(
    create = "
      CREATE TABLE gene_types (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        display VARCHAR,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX gene_type_name_index ON gene_types (\"name\");"
    )
  ),
  genes_to_samples = list(
    create = "
      CREATE TABLE genes_to_samples (
        gene_id INTEGER NOT NULL,
        sample_id INTEGER NOT NULL,
        rna_seq_expr NUMERIC,
        PRIMARY KEY (gene_id, sample_id)
      );",
    addSchema = c(
      "CREATE INDEX gene_to_sample_sample_id_index ON genes_to_samples (sample_id, gene_id);",
      "ALTER TABLE genes_to_samples ADD FOREIGN KEY (gene_id) REFERENCES genes;",
      "ALTER TABLE genes_to_samples ADD FOREIGN KEY (sample_id) REFERENCES samples;"
    )
  ),
  genes_to_types = list(
    create = "
      CREATE TABLE genes_to_types (
        gene_id INTEGER,
        type_id INTEGER,
        PRIMARY KEY (gene_id, type_id)
      );",
    addSchema = c(
      "CREATE INDEX gene_to_type_type_id_index ON genes_to_types (type_id);",
      "ALTER TABLE genes_to_types ADD FOREIGN KEY (gene_id) REFERENCES genes;",
      "ALTER TABLE genes_to_types ADD FOREIGN KEY (type_id) REFERENCES gene_types;"
    )
  ),
  immune_checkpoints = list(
    create = "
      CREATE TABLE immune_checkpoints (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX immune_checkpoint_name_index ON immune_checkpoints (\"name\");"
    )
  ),
  method_tags = list(
    create = "
      CREATE TABLE method_tags (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX method_tag_name_index ON method_tags (\"name\");"
    )
  ),
  mutations = list(
    create = "
      CREATE TABLE mutations (
        id SERIAL,
        gene_id INTEGER NOT NULL,
        mutation_code_id INTEGER NOT NULL,
        mutation_type_id INTEGER,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE INDEX mutation_gene_id_mutation_code_id_mutation_type_id_index ON mutations (gene_id, mutation_code_id, mutation_type_id);",
      "CREATE INDEX mutation_mutation_code_id_index ON mutations (mutation_code_id);",
      "CREATE INDEX mutation_mutation_type_id_index ON mutations (mutation_type_id);",
      "ALTER TABLE mutations ADD FOREIGN KEY (gene_id) REFERENCES genes;",
      "ALTER TABLE mutations ADD FOREIGN KEY (mutation_code_id) REFERENCES mutation_codes;",
      "ALTER TABLE mutations ADD FOREIGN KEY (mutation_type_id) REFERENCES mutation_types;"
    )
  ),
  mutation_codes = list (
    create = "
      CREATE TABLE mutation_codes (
        id SERIAL,
        code VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );"
  ),
  mutation_types = list(
    create = "
      CREATE TABLE mutation_types (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        display VARCHAR,
        PRIMARY KEY (id)
      );"
  ),
  nodes = list(
    create = "
      CREATE TABLE nodes (
        id SERIAL,
        name VARCHAR NOT NULL,
        dataset_id INTEGER NOT NULL,
        feature_id INTEGER,
        gene_id INTEGER,
        label VARCHAR,
        score NUMERIC,
        x NUMERIC,
        y NUMERIC,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE INDEX node_feature_id_index ON nodes (feature_id);",
      "CREATE INDEX node_gene_id_index ON nodes (gene_id);",
      "ALTER TABLE nodes ADD FOREIGN KEY (feature_id) REFERENCES features;",
      "ALTER TABLE nodes ADD FOREIGN KEY (dataset_id) REFERENCES datasets;",
      "ALTER TABLE nodes ADD FOREIGN KEY (gene_id) REFERENCES genes;"
    )
  ),
  nodes_to_tags = list(
    create = "
      CREATE TABLE nodes_to_tags (
        node_id INTEGER,
        tag_id INTEGER,
        PRIMARY KEY (node_id, tag_id)
      );",
    addSchema = c(
      "CREATE INDEX nodes_to_tag_tag_id_index ON nodes_to_tags (tag_id);",
      "ALTER TABLE nodes_to_tags ADD FOREIGN KEY (node_id) REFERENCES nodes;",
      "ALTER TABLE nodes_to_tags ADD FOREIGN KEY (tag_id) REFERENCES tags;"
    )
  ),
  pathways = list(
    create = "
      CREATE TABLE pathways (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX pathway_name_index ON pathways (\"name\");"
    )
  ),
  patients = list(
    create = "
      CREATE TABLE patients (
        id SERIAL,
        age INTEGER,
        barcode VARCHAR,
        ethnicity VARCHAR,
        gender VARCHAR,
        height NUMERIC,
        race VARCHAR,
        \"weight\" NUMERIC,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE INDEX patient_age_index ON patients (age);",
      "CREATE INDEX patient_barcode_index ON patients (barcode);",
      "CREATE INDEX patient_ethnicity_index ON patients (ethnicity);",
      "CREATE INDEX patient_gender_index ON patients (gender);",
      "CREATE INDEX patient_height_index ON patients (height);",
      "CREATE INDEX patient_race_index ON patients (race);",
      "CREATE INDEX patient_weight_index ON patients (\"weight\");"
    )
  ),
  publications = list(
    create = "
      CREATE TABLE publications (
        id SERIAL,
        pubmed_id INTEGER NOT NULL,
        journal VARCHAR,
        first_author_last_name VARCHAR,
        year INTEGER,
        title VARCHAR,
        PRIMARY KEY (id)
      );",
    addSchema = c(
    )
  ),
  publications_to_genes = list(
    create = "
      CREATE TABLE publications_to_genes (
        publication_id INTEGER NOT NULL,
        gene_id INTEGER NOT NULL,
        PRIMARY KEY (publication_id, gene_id)
      );",
    addSchema = c(
      "CREATE INDEX publications_to_genes_publication_id_index ON publications_to_genes (publication_id);",
      "ALTER TABLE publications_to_genes ADD FOREIGN KEY (publication_id) REFERENCES publications;",
      "ALTER TABLE publications_to_genes ADD FOREIGN KEY (gene_id) REFERENCES genes;"
    )
  ),
  samples = list(
    create = "
      CREATE TABLE samples (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        patient_id INTEGER NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX sample_name_index ON samples (\"name\");",
      "CREATE INDEX sample_patient_index ON samples (patient_id);",
      "ALTER TABLE samples ADD FOREIGN KEY (patient_id) REFERENCES patients;"
    )
  ),
  samples_to_mutations = list(
    create = "
      CREATE TABLE samples_to_mutations (
        sample_id INTEGER NOT NULL,
        mutation_id INTEGER NOT NULL,
        \"status\" STATUS_ENUM,
        PRIMARY KEY (sample_id, mutation_id)
      );",
    addSchema = c(
      "CREATE INDEX sample_to_mutation_mutation_id_index ON samples_to_mutations (mutation_id);",
      "ALTER TABLE samples_to_mutations ADD FOREIGN KEY (sample_id) REFERENCES samples;",
      "ALTER TABLE samples_to_mutations ADD FOREIGN KEY (mutation_id) REFERENCES mutations;"
    )
  ),
  samples_to_tags = list(
    create = "
      CREATE TABLE samples_to_tags (
        sample_id INTEGER,
        tag_id INTEGER,
        PRIMARY KEY (sample_id, tag_id)
      );",
    addSchema = c(
      "CREATE INDEX sample_to_tag_tag_id_index ON samples_to_tags (tag_id);",
      "ALTER TABLE samples_to_tags ADD FOREIGN KEY (sample_id) REFERENCES samples;",
      "ALTER TABLE samples_to_tags ADD FOREIGN KEY (tag_id) REFERENCES tags;"
    )
  ),
  slides = list(
    create = "
      CREATE TABLE slides (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        \"description\" VARCHAR,
        patient_id INTEGER NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX slide_name_index ON slides (\"name\");",
      "CREATE INDEX slide_patient_index ON slides (patient_id);",
      "ALTER TABLE slides ADD FOREIGN KEY (patient_id) REFERENCES patients;"
    )
  ),
  super_categories = list(
    create = "
      CREATE TABLE super_categories (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX super_category_name_index ON super_categories (\"name\");"
    )
  ),
  tags = list(
    create = "
      CREATE TABLE tags (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        characteristics VARCHAR,
        display VARCHAR,
        color VARCHAR,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX tag_name_index ON tags (\"name\");"
    )
  ),
  tags_to_tags = list(
    create = "
      CREATE TABLE tags_to_tags (
        tag_id INTEGER NOT NULL,
        related_tag_id INTEGER NOT NULL,
        PRIMARY KEY (tag_id, related_tag_id)
      );",
    addSchema = c(
      "CREATE INDEX tag_to_tag_related_tag_id_index ON tags_to_tags (related_tag_id);",
      "ALTER TABLE tags_to_tags ADD FOREIGN KEY (related_tag_id) REFERENCES tags;",
      "ALTER TABLE tags_to_tags ADD FOREIGN KEY (tag_id) REFERENCES tags;"
    )
  ),
  therapy_types = list(
    create = "
      CREATE TABLE therapy_types (
        id SERIAL,
        \"name\" VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX therapy_type_name_index ON therapy_types (\"name\");"
    )
  )
)

#' table_a is_dependent_table on table_b
is_dependent_table <- function (a, b) {
  grepl(paste0("REFERENCES ", b), sql_schema[[a]]$addSchema) %>%
  purrr::detect(~ ., .default = FALSE)
}

get_dependent_tables_recursive <- function (table_name) {
  purrr::map(names(sql_schema), ~ if (is_dependent_table(., table_name)) c(get_dependent_tables_recursive(.), .))
}

get_dependent_tables <- function (table_name) {
  get_dependent_tables_recursive(table_name) %>%
  unlist() %>%
  purrr::compact()
}
