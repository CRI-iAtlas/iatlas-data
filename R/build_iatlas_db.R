#' build_iatlas_db
#'
#' Build the full iAtlas database from source feather=files
#'
#' @param env
#' @param reset "reset" or "create" or NULL
#' @param resume_at = NULL or step-name-string - will skip all steps until the specified step, which will be executed as well as all following steps
#' resume_at can also == "auto" and it will resume at the previous fail-point, or, if none, it will start at the top
#'
#' @param stop_at = NULL or step-name-string - will stop executing AFTER executing the specified step. Will not execute any more steps.
#' @return nothing
build_iatlas_db <- function(env = "dev", reset = "reset", resume_at = NULL, stop_at = NULL, feather_file_folder = "feather_files", script_path = "scripts") {

  load_config(env)

  .GlobalEnv$create_db_en_env <- function() {iatlas.data::create_db(env, reset, script_path = script_path)}

  iatlas.data::set_feather_file_folder(feather_file_folder)

  iatlas.data::build_pipeline(
    c(
      "create_db_en_env",
      "build_features_tables",
      "build_tags_tables",
      "build_genes_tables",
      "build_gene_types_table",
      "build_genes_to_types_table",
      "build_mutation_codes_table",
      "build_mutation_codes_to_gene_types_table",
      "build_patients_table",
      "build_slides_table",
      "build_samples_table",
      "build_samples_to_tags_table",
      "build_features_to_samples_table",
      "build_genes_to_samples_table",
      "build_genes_samples_mutations_table",
      "build_driver_results_table",
      "build_nodes_tables"
    ),
    resume_at = resume_at,
    stop_at = stop_at,
    finally = {
      iatlas.data::reset_results_cache()
      iatlas.data::release_global_db_pool()
    }
  )
}
