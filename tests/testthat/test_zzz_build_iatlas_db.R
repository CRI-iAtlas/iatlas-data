(function() {
  library("testthat")
  library('feather')
  source('./lib_test_data.R')

  with_test_db_env({
    test_that("build_iatlas_db", {
      iatlas.data::build_iatlas_db(env="test", feather_file_folder = get_test_data_path("feather_files"))
      expect_true(table_exists("genes"))
    })

    purrr::map(names(sql_schema), function(table_name) {
      test_that(paste0(table_name," exists"), {
        expect_true(table_exists(table_name))
      })
    })
    # set_feather_file_folder(get_test_data_path("feather_files"))

    # build_steps = c(
    #   "build_features_tables",
    #   "build_tags_tables",
    #   "build_genes_tables",
    #   "build_gene_types_table",
    #   "build_genes_to_types_table",
    #   "build_mutation_codes_table",
    #   "build_mutation_codes_to_gene_types_table",
    #   "build_patients_table",
    #   "build_slides_table",
    #   "build_samples_table",
    #   "build_samples_to_tags_table",
    #   "build_features_to_samples_table",
    #   "build_genes_to_samples_table",
    #   "build_genes_samples_mutations_table",
    #   "build_driver_results_table",
    #   "build_nodes_tables"
    # )


    # for (build_step in build_steps) {
    #   test_that(build_step, {
    #     f <- match.fun(build_step)
    #     cat(crayon::bold(crayon::blue("\n\n\n---------------------------------------\nSTART:", build_step,"\n")))
    #     tictoc::tic(paste0("Time taken to run: ", build_step))
    #     tryCatch(f(), catch=function (error) {
    #       cat("error: ", error)
    #       stop(error)
    #     })
    #     expect_equal("todo","todo")
    #     tictoc::toc()
    #     cat(crayon::bold(crayon::green("\nSUCCESS:", build_step,"\n---------------------------------------\n\n")))
    #   })
    # }

    # teardown(release_global_db_pool())
  })
})()
