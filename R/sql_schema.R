sql_schema <- list(
  classes = list(
    create = "
      CREATE TABLE classes (
        id SERIAL,
        name VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX class_name_index ON classes (name);"
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
        tag_id INTEGER,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE INDEX driver_results_feature_id_index ON driver_results (feature_id);",
      "CREATE INDEX driver_results_gene_id_index ON driver_results (gene_id);",
      "CREATE INDEX driver_results_tag_id_id_index ON driver_results (tag_id);",
      "ALTER TABLE driver_results ADD FOREIGN KEY (feature_id) REFERENCES features;",
      "ALTER TABLE driver_results ADD FOREIGN KEY (gene_id) REFERENCES genes;",
      "ALTER TABLE driver_results ADD FOREIGN KEY (tag_id) REFERENCES tags;"
    )
  ),
  edges = list (
    create = "
      CREATE TABLE edges (
        id SERIAL,
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
        name VARCHAR NOT NULL,
        display VARCHAR,
        order INTEGER,
        unit UNIT_ENUM,
        class_id INTEGER REFERENCES classes NOT NULL,
        method_tag_id INTEGER REFERENCES method_tags,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX feature_name_index ON features (name);",
      "CREATE INDEX feature_class_id_index ON features (class_id);",
      "CREATE INDEX feature_method_tag_id_index ON features (method_tag_id);"
    )
  ),
  features_to_samples = list(
    create = "
      CREATE TABLE features_to_samples (
        feature_id INTEGER,
        sample_id INTEGER,
        value NUMERIC,
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
        gene_family_id INTEGER REFERENCES gene_families,
        gene_function_id INTEGER REFERENCES gene_functions,
        immune_checkpoint_id INTEGER REFERENCES immune_checkpoints,
        node_type_id INTEGER REFERENCES node_types,
        pathway_id INTEGER REFERENCES pathways,
        references TEXT[],
        super_cat_id INTEGER REFERENCES super_categories,
        therapy_type_id INTEGER REFERENCES therapy_types,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX gene_entrez_index ON genes (entrez);",
      "CREATE UNIQUE INDEX gene_hgnc_index ON genes (hgnc);",
      "CREATE INDEX gene_gene_family_id_index ON genes (gene_family_id);",
      "CREATE INDEX gene_gene_function_id_index ON genes (gene_function_id);",
      "CREATE INDEX gene_immune_checkpoint_id_index ON genes (immune_checkpoint_id);",
      "CREATE INDEX gene_node_type_id_index ON genes (node_type_id);",
      "CREATE INDEX gene_pathway_id_index ON genes (pathway_id);",
      "CREATE INDEX gene_super_cat_id_index ON genes (super_cat_id);",
      "CREATE INDEX gene_therapy_type_id_index ON genes (therapy_type_id);"
    )
  ),
  gene_families = list(
    create = "
      CREATE TABLE gene_families (
        id SERIAL,
        name VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX gene_family_name_index ON gene_families (name);"
    )
  ),
  gene_functions = list(
    create = "
      CREATE TABLE gene_functions (
        id SERIAL,
        name VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX gene_function_name_index ON gene_functions (name);"
    )
  ),
  genes_samples_mutation = list(
    create = "
      CREATE TABLE genes_samples_mutation (
        gene_id INTEGER NOT NULL,
        sample_id INTEGER NOT NULL,
        mutation_code_id INTEGER NOT NULL,
        status STATUS_ENUM,
        PRIMARY KEY (gene_id, sample_id, mutation_code_id)
      );",
    addSchema = c(
      "CREATE INDEX gene_sample_mutation_sample_id_index ON genes_samples_mutation (sample_id, gene_id);",
      "ALTER TABLE genes_samples_mutation ADD FOREIGN KEY (gene_id) REFERENCES genes;",
      "ALTER TABLE genes_samples_mutation ADD FOREIGN KEY (sample_id) REFERENCES samples;",
      "ALTER TABLE genes_samples_mutation ADD FOREIGN KEY (mutation_code_id) REFERENCES mutation_codes;"
    )
  ),
  gene_types = list(
    create = "
      CREATE TABLE gene_types (
        id SERIAL,
        name VARCHAR NOT NULL,
        display VARCHAR,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX gene_type_name_index ON gene_types (name);"
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
        gene_id INTEGER REFERENCES genes,
        type_id INTEGER REFERENCES gene_types,
        PRIMARY KEY (gene_id, type_id)
      );",
    addSchema = c(
      "CREATE INDEX gene_to_type_type_id_index ON genes_to_types (type_id);"
    )
  ),
  immune_checkpoints = list(
    create = "
      CREATE TABLE immune_checkpoints (
        id SERIAL,
        name VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX immune_checkpoint_name_index ON immune_checkpoints (name);"
    )
  ),
  method_tags = list(
    create = "
      CREATE TABLE method_tags (
        id SERIAL,
        name VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX method_tag_name_index ON method_tags (name);"
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
  mutation_codes_to_gene_types = list (
    create = "
      CREATE TABLE mutation_codes_to_gene_types (
        mutation_code_id INTEGER REFERENCES mutation_codes,
        type_id INTEGER REFERENCES gene_types,
        PRIMARY KEY (mutation_code_id, type_id)
      );",
    addSchema = c(
      "CREATE INDEX mutation_codes_to_gene_type_type_id_index ON mutation_codes_to_gene_types (type_id);"
    )
  ),
  node_types = list(
    create = "
      CREATE TABLE node_types (
        id SERIAL,
        name VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX node_type_name_index ON node_types (name);"
    )
  ),
  nodes = list (
    create = "
      CREATE TABLE nodes (
        id SERIAL,
        feature_id INTEGER,
        gene_id INTEGER,
        score NUMERIC,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE INDEX node_feature_id_index ON nodes (feature_id);",
      "CREATE INDEX node_gene_id_index ON nodes (gene_id);",
      "ALTER TABLE nodes ADD FOREIGN KEY (feature_id) REFERENCES features;",
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
        name VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX pathway_name_index ON pathways (name);"
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
        weight NUMERIC,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE INDEX patient_age_index ON patients (age);",
      "CREATE INDEX patient_barcode_index ON patients (barcode);",
      "CREATE INDEX patient_ethnicity_index ON patients (ethnicity);",
      "CREATE INDEX patient_gender_index ON patients (gender);",
      "CREATE INDEX patient_height_index ON patients (height);",
      "CREATE INDEX patient_race_index ON patients (race);",
      "CREATE INDEX patient_weight_index ON patients (weight);"
    )
  ),
  patients_to_slides = list(
    create = "
      CREATE TABLE patients_to_slides (
        patient_id INTEGER,
        slide_id INTEGER,
        PRIMARY KEY (patient_id, slide_id)
      );",
    addSchema = c(
      "CREATE INDEX patients_to_slides_slide_id_index ON patients_to_slides (slide_id);",
      "ALTER TABLE patients_to_slides ADD FOREIGN KEY (patient_id) REFERENCES patients;",
      "ALTER TABLE patients_to_slides ADD FOREIGN KEY (slide_id) REFERENCES slides;"
    )
  ),
  samples = list(
    create = "
      CREATE TABLE samples (
        id SERIAL,
        name VARCHAR NOT NULL,
        patient_id INTEGER NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX sample_name_index ON samples (name);",
      "CREATE UNIQUE INDEX sample_patient_index ON samples (patient_id);",
      "ALTER TABLE samples ADD FOREIGN KEY (patient_id) REFERENCES patients;"
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
        name VARCHAR NOT NULL,
        description VARCHAR,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX slide_name_index ON slides (name);"
    )
  ),
  super_categories = list(
    create = "
      CREATE TABLE super_categories (
        id SERIAL,
        name VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX super_category_name_index ON super_categories (name);"
    )
  ),
  tags = list(
    create = "
      CREATE TABLE tags (
        id SERIAL,
        name VARCHAR NOT NULL,
        characteristics VARCHAR,
        display VARCHAR,
        color VARCHAR,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX tag_name_index ON tags (name);"
    )
  ),
  tags_to_tags = list(
    create = "
      CREATE TABLE tags_to_tags (
        tag_id INTEGER REFERENCES tags NOT NULL,
        related_tag_id INTEGER REFERENCES tags NOT NULL,
        PRIMARY KEY (tag_id, related_tag_id)
      );",
    addSchema = c(
      "CREATE INDEX tag_to_tag_related_tag_id_index ON tags_to_tags (related_tag_id);"
    )
  ),
  therapy_types = list(
    create = "
      CREATE TABLE therapy_types (
        id SERIAL,
        name VARCHAR NOT NULL,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX therapy_type_name_index ON therapy_types (name);"
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