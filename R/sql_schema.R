sql_schema <- list(
  samples = list( # WIP
    create = "
      CREATE TABLE samples (
        id SERIAL,
        name VARCHAR NOT NULL,
        tissue_id VARCHAR,
        PRIMARY KEY (id)
      );",
    addSchema = c(
      "CREATE UNIQUE INDEX sample_name_index ON samples (name);"
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
        feature_id INTEGER REFERENCES features,
        sample_id INTEGER REFERENCES samples,
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
        gene_id INTEGER NOT NULL,
        sample_id INTEGER NOT NULL,
        mutation_code_id INTEGER NOT NULL,
        rna_seq_expr NUMERIC,
        status STATUS_ENUM,
        PRIMARY KEY (gene_id, sample_id, mutation_code_id)
      );",
    addSchema = c(
      "CREATE INDEX gene_to_sample_gene_id_sample_id_index ON genes_to_samples (gene_id, sample_id);",
      "CREATE INDEX gene_to_sample_mutation_code_id_index ON genes_to_samples (mutation_code_id);",
      "CREATE INDEX gene_to_sample_sample_id_index ON genes_to_samples (sample_id);",
      "ALTER TABLE genes_to_samples ADD FOREIGN KEY (gene_id) REFERENCES genes;",
      "ALTER TABLE genes_to_samples ADD FOREIGN KEY (sample_id) REFERENCES samples;",
      "ALTER TABLE genes_to_samples ADD FOREIGN KEY (mutation_code_id) REFERENCES mutation_codes;"
    )
  )
)
