-- Create STATUS_ENUM ENUM
DO $$ BEGIN
    CREATE TYPE STATUS_ENUM AS ENUM ('Wt', 'Mut');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create UNIT_ENUM ENUM
DO $$ BEGIN
    CREATE TYPE UNIT_ENUM AS ENUM ('Count', 'Fraction', 'Per Megabase', 'Score', 'Year' );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- samples table
CREATE TABLE patients (
    id SERIAL,
    gender VARCHAR,
    race VARCHAR,
    ethnicity VARCHAR,
    PRIMARY KEY (id)
);
CREATE INDEX patient_gender_index ON patients (gender);
CREATE INDEX patient_race_index ON patients (race);
CREATE INDEX patient_ethnicity_index ON patients (ethnicity);

-- samples table
CREATE TABLE samples (
    id SERIAL,
    sample_id VARCHAR NOT NULL,
    tissue_id VARCHAR,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX sample_sample_id_index ON samples (sample_id);

-- gene_families table
CREATE TABLE gene_families (id SERIAL, "name" VARCHAR NOT NULL, PRIMARY KEY (id));
CREATE UNIQUE INDEX gene_family_name_index ON gene_families ("name");

-- gene_functions table
CREATE TABLE gene_functions (id SERIAL, "name" VARCHAR NOT NULL, PRIMARY KEY (id));
CREATE UNIQUE INDEX gene_function_name_index ON gene_functions ("name");

-- gene_types table
CREATE TABLE gene_types (id SERIAL, "name" VARCHAR NOT NULL, display VARCHAR, PRIMARY KEY (id));
CREATE UNIQUE INDEX gene_type_name_index ON gene_types ("name");

-- immune_checkpoints table
CREATE TABLE immune_checkpoints (id SERIAL, "name" VARCHAR NOT NULL, PRIMARY KEY (id));
CREATE UNIQUE INDEX immune_checkpoint_name_index ON immune_checkpoints ("name");

-- pathways table
CREATE TABLE pathways (id SERIAL, "name" VARCHAR NOT NULL, PRIMARY KEY (id));
CREATE UNIQUE INDEX pathway_name_index ON pathways ("name");

-- super_categories table
CREATE TABLE super_categories (id SERIAL, "name" VARCHAR NOT NULL, PRIMARY KEY (id));
CREATE UNIQUE INDEX super_categorie_name_index ON super_categories ("name");

-- therapy_types table
CREATE TABLE therapy_types (id SERIAL, "name" VARCHAR NOT NULL, PRIMARY KEY (id));
CREATE UNIQUE INDEX therapy_type_name_index ON therapy_types ("name");

-- classes table
CREATE TABLE classes (id SERIAL, "name" VARCHAR NOT NULL, PRIMARY KEY (id));
CREATE UNIQUE INDEX class_name_index ON classes ("name");

-- method_tags table
CREATE TABLE method_tags (id SERIAL, "name" VARCHAR NOT NULL, PRIMARY KEY (id));
CREATE UNIQUE INDEX method_tag_name_index ON method_tags ("name");

-- tags table
CREATE TABLE tags (
    id SERIAL,
    "name" VARCHAR NOT NULL,
    characteristics VARCHAR,
    display VARCHAR,
    color VARCHAR,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX tag_name_index ON tags ("name");

-- tags_to_tags table
CREATE TABLE tags_to_tags (
    tag_id INTEGER REFERENCES tags NOT NULL,
    related_tag_id INTEGER REFERENCES tags NOT NULL,
    PRIMARY KEY (tag_id, related_tag_id)
);
CREATE INDEX tag_to_tag_related_tag_id_index ON tags_to_tags (related_tag_id);

-- features table
CREATE TABLE features (
    id SERIAL,
    "name" VARCHAR NOT NULL,
    display VARCHAR,
    "order" INTEGER,
    unit UNIT_ENUM,
    class_id INTEGER REFERENCES classes NOT NULL,
    method_tag_id INTEGER REFERENCES method_tags,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX feature_name_index ON features ("name");
CREATE INDEX feature_class_id_index ON features (class_id);
CREATE INDEX feature_method_tag_id_index ON features (method_tag_id);

-- genes table
CREATE TABLE genes (
    id SERIAL,
    entrez INTEGER,
    hgnc VARCHAR NOT NULL,
    "description" VARCHAR,
    "friendly_name" VARCHAR,
    "io_landscape_name" VARCHAR,
    gene_family_id INTEGER REFERENCES gene_families,
    gene_function_id INTEGER REFERENCES gene_functions,
    immune_checkpoint_id INTEGER REFERENCES immune_checkpoints,
    pathway_id INTEGER REFERENCES pathways,
    "references" TEXT[],
    super_cat_id INTEGER REFERENCES super_categories,
    therapy_type_id INTEGER REFERENCES therapy_types,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX gene_entrez_index ON genes (entrez);
CREATE UNIQUE INDEX gene_hgnc_index ON genes (hgnc);
CREATE INDEX gene_gene_family_id_index ON genes (gene_family_id);
CREATE INDEX gene_gene_function_id_index ON genes (gene_function_id);
CREATE INDEX gene_immune_checkpoint_id_index ON genes (immune_checkpoint_id);
CREATE INDEX gene_pathway_id_index ON genes (pathway_id);
CREATE INDEX gene_super_cat_id_index ON genes (super_cat_id);
CREATE INDEX gene_therapy_type_id_index ON genes (therapy_type_id);

-- mutation_codes table
CREATE TABLE mutation_codes (
    id SERIAL,
    code VARCHAR NOT NULL,
    PRIMARY KEY (id)
);

-- driver_results table
CREATE TABLE driver_results (
    id SERIAL,
    p_value NUMERIC,
    fold_change NUMERIC,
    log10_p_value NUMERIC,
    log10_fold_change NUMERIC,
    n_wt INTEGER,
    n_mut INTEGER,
    feature_id INTEGER REFERENCES features,
    gene_id INTEGER REFERENCES genes,
    tag_id INTEGER REFERENCES tags,
    PRIMARY KEY (id)
);
CREATE INDEX driver_results_feature_id_index ON driver_results (feature_id);
CREATE INDEX driver_results_gene_id_index ON driver_results (gene_id);
CREATE INDEX driver_results_tag_id_id_index ON driver_results (tag_id);

-- nodes table
CREATE TABLE nodes (
    id SERIAL,
    feature_id INTEGER REFERENCES features,
    gene_id INTEGER REFERENCES genes,
    score NUMERIC,
    PRIMARY KEY (id)
);
CREATE INDEX node_feature_id_index ON nodes (feature_id);
CREATE INDEX node_gene_id_index ON nodes (gene_id);

-- edges table
CREATE TABLE edges (
    id SERIAL,
    node_1_id INTEGER REFERENCES nodes NOT NULL,
    node_2_id INTEGER REFERENCES nodes NOT NULL,
    ratio_score NUMERIC,
    PRIMARY KEY (id)
);
CREATE INDEX edge_node_2_id_index ON edges (node_2_id);
CREATE INDEX edge_nodes_id_index ON edges (node_1_id, node_2_id);

-- genes_to_types table
CREATE TABLE genes_to_types (
    gene_id INTEGER REFERENCES genes,
    "type_id" INTEGER REFERENCES gene_types,
    PRIMARY KEY (gene_id, "type_id")
);
CREATE INDEX gene_to_type_type_id_index ON genes_to_types ("type_id");

-- mutation_codes_to_gene_types table
CREATE TABLE mutation_codes_to_gene_types (
    mutation_code_id INTEGER REFERENCES mutation_codes,
    "type_id" INTEGER REFERENCES gene_types,
    PRIMARY KEY (mutation_code_id, "type_id")
);
CREATE INDEX mutation_codes_to_gene_type_type_id_index ON mutation_codes_to_gene_types ("type_id");

-- genes_to_samples table
CREATE TABLE genes_to_samples (
    gene_id INTEGER REFERENCES genes NOT NULL,
    sample_id INTEGER REFERENCES samples NOT NULL,
    mutation_code_id INTEGER REFERENCES mutation_codes NOT NULL,
    "rna_seq_expr" NUMERIC,
    "status" STATUS_ENUM,
    PRIMARY KEY (gene_id, sample_id, mutation_code_id)
);
CREATE INDEX gene_to_sample_gene_id_sample_id_index ON genes_to_samples (gene_id, sample_id);
CREATE INDEX gene_to_sample_mutation_code_id_index ON genes_to_samples (mutation_code_id);
CREATE INDEX gene_to_sample_sample_id_index ON genes_to_samples (sample_id);

-- samples_to_tags table
CREATE TABLE samples_to_tags (
    sample_id INTEGER REFERENCES samples,
    tag_id INTEGER REFERENCES tags,
    PRIMARY KEY (sample_id, tag_id)
);
CREATE INDEX sample_to_tag_tag_id_index ON samples_to_tags (tag_id);

-- features_to_samples table
CREATE TABLE features_to_samples (
    feature_id INTEGER REFERENCES features,
    sample_id INTEGER REFERENCES samples,
    "value" NUMERIC,
    "inf_value" REAL,
    PRIMARY KEY (feature_id, sample_id)
);
CREATE INDEX feature_to_sample_sample_id_index ON features_to_samples (sample_id);

-- nodes_to_tags table
CREATE TABLE nodes_to_tags (
    node_id INTEGER REFERENCES nodes,
    tag_id INTEGER REFERENCES tags,
    PRIMARY KEY (node_id, tag_id)
);
CREATE INDEX nodes_to_tag_tag_id_index ON nodes_to_tags (tag_id);
