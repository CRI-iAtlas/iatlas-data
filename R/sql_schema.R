sql_schema <- list(
  samples = list( # WIP
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
  genes_to_samples = list(
    create = "
      CREATE TABLE genes_to_samples (
        id SERIAL,
        gene_id INTEGER NOT NULL,
        sample_id INTEGER NOT NULL,
        mutation_code_id INTEGER,
        rna_seq_expr NUMERIC,
        status STATUS_ENUM,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX gene_to_sample_gene_id_sample_id_index ON genes_to_samples (gene_id, sample_id, mutation_code_id);",
      "CREATE INDEX gene_to_sample_sample_id_index ON genes_to_samples (sample_id, gene_id);",
      "ALTER TABLE genes_to_samples ADD FOREIGN KEY (gene_id) REFERENCES genes;",
      "ALTER TABLE genes_to_samples ADD FOREIGN KEY (sample_id) REFERENCES samples;",
      "ALTER TABLE genes_to_samples ADD FOREIGN KEY (mutation_code_id) REFERENCES mutation_codes;"
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
      "CREATE INDEX patient_race_index ON patients (race);"
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