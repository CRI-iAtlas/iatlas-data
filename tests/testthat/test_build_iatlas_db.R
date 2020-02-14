(function() {
  library("testthat")
  library('feather')
  source('./lib_test_data.R')


  # route_logs_to_file()

  with_test_db_env({
    set_feather_file_folder(get_test_data_path("feather_files"))

    test_that("create_db", {
      iatlas.data::create_db("test", "reset", '../scripts')
      expect_equal("todo","todo")
    })

    build_steps = c(
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
    )


    for (build_step in build_steps) {
      test_that(build_step, {
        f <- match.fun(build_step)
        log_info(crayon::bold(crayon::blue("\n\n\n---------------------------------------\nSTART:", build_step,"\n")))
        tictoc::tic(paste0("Time taken to run: ", build_step))
        tryCatch(f(), catch=function (error) {
          log_info("error: ", error)
          stop(error)
        })
        expect_equal("todo","todo")
        tictoc::toc()
        log_info(crayon::bold(crayon::green("\nSUCCESS:", build_step,"\n---------------------------------------\n\n")))
      })
    }

  #   test_that("old_build_features_tables", {
  #     iatlas.data::old_build_features_tables(feather_file_folder)
  #     expect_equal("todo","todo")
  #   })

  #   test_that("old_build_tags_tables", {
  #     iatlas.data::old_build_tags_tables(feather_file_folder)
  #     expect_equal("todo","todo")
  #   })

  #   test_that("old_build_genes_tables", {
  #     iatlas.data::old_build_genes_tables(feather_file_folder)
  #     expect_equal("todo","todo")
  #   })

  #   test_that("run rest", {
  #     set_feather_file_folder(feather_file_folder)

  #     old_build_patients_table()
  #     old_build_samples_table()
  #     old_build_samples_to_tags_table()
  #     old_build_features_to_samples_table()
  #     old_build_genes_to_samples_table()
  #     old_build_slides_table()

  #     reset_results_cache()

  #     # after build-samples-tables ---------------------------------------------------
  #     old_build_driver_results_tables(feather_file_folder)
  #     old_build_nodes_tables(paste0(feather_file_folder, "/SQLite_data"))
  #     expect_equal("todo","todo")
  #   })

  #   teardown(log_info("test_old_build_iatlast_db TEARDOWN"))

  #   teardown(pool::poolClose(.GlobalEnv$pool))
  #   teardown(rm(pool, pos = ".GlobalEnv"))
  })
})()
