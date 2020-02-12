(function() {
  library("testthat")
  library('feather')
  source('./lib_test_data.R')
  library('logging')
  iatlas.data::route_logs_to_file()

  .GlobalEnv$pool <- NULL

  # with_test_db_env({
  #   feather_file_folder <- get_test_data_path("feather_files")

  #   test_that("create_db", {
  #     iatlas.data::create_db("test", "reset", '../scripts')
  #     expect_equal("fun", "fun")
  #   })

  #   test_that("connect_db", {
  #     cat(crayon::bold(paste0("connect to db: ", .GlobalEnv$DB_NAME)), fill=)
  #     .GlobalEnv$pool <- connect_to_db()
  #     expect_equal(.GlobalEnv$DB_NAME, "iatlas_shiny_test")
  #   })

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
  # })
})()
