# Database helper functions.

create_global_db_pool <- function() {
  if (!iatlas.data::present(.GlobalEnv$pool)) {
    .GlobalEnv$pool <- iatlas.data::connect_to_db()
  } else {
    cat(crayon::yellow("WARNING-create_global_db_pool: global db pool already created\n"))
    .GlobalEnv$pool
  }
}

vivify_global_db_pool <- function() {
  if (!iatlas.data::present(.GlobalEnv$pool)) create_global_db_pool()
  else .GlobalEnv$pool
}

release_global_db_pool <- function() {
  if (iatlas.data::present(.GlobalEnv$pool)) {
    pool::poolClose(.GlobalEnv$pool)
    rm(pool, pos = ".GlobalEnv")
  } else {
    cat(crayon::yellow("WARNING-release_global_db_pool: Nothing to do. Global db pool does not exist. \n"))
  }
}

with_db_pool <- function(f) {
  connection <- pool::poolCheckout(vivify_global_db_pool())
  on.exit({
    pool::poolReturn(connection)
  })

  f(connection)
}

timed_with_db_pool <- function(context, f, slow = FALSE) {
  if (slow) cat(paste0("START: ", context, "\n"))
  tictoc::tic(paste0("DONE:  ", context))
  on.exit(tictoc::toc())
  tryCatch(
    with_db_pool(f),
    error = function(e) {
      cat(crayon::red(paste0("error: ", e,"\nin: ", context)), fill = TRUE)
      stop(e)
    }
  )
}

table_exists <- function(table_name)
  with_db_pool(function(connection) pool::dbExistsTable(connection, table_name))

read_table <- function(table_name)
  with_db_pool(function(connection) pool::dbReadTable(connection, table_name))

drop_table <- function(table_name) {
  if (table_exists(table_name))
    db_execute(paste0("DROP TABLE ", table_name))
}

db_execute <- function(query, ...)
  timed_with_db_pool(
    paste0("dbExecute: ", query),
    function(connection) pool::dbExecute(connection, query),
    ...
  )

validate_control_data <- function (data, table_name) {
  control_folder <- "./control_data/"
  control_file <- paste0(control_folder, table_name, ".feather")
  if (iatlas.data::present(.GlobalEnv$snapshot_control_data))
    rm(snapshot_control_data, pos = .GlobalEnv)

  if (file.exists(control_folder)) {
    if (file.exists(control_file)) {
      cat(crayon::magenta(paste0("Validating data for ", table_name, " (", nrow(data), " rows)...\n")))
      control_data <- feather::read_feather(control_file)
      if (dplyr::all_equal(control_data, data) == TRUE)
        cat(crayon::bold(crayon::green(paste0("PASS: control data for ", table_name, " is identical\n"))))
      else {
        .GlobalEnv[[paste0(table_name,"_data")]] <- data
        .GlobalEnv[[paste0(table_name,"_control_data")]] <- control_data
        cat(paste0(
          crayon::bold(crayon::red("FAIL: control data for", table_name, "is different.\n")),
          "Both versions have been stored in the global environment:\n",
          "  - ", table_name, "_data\n",
          "  - ", table_name, "_control_data\n",
          "To accept the new version, run: ", crayon::bold("update_control_data_snapshot()\n")
        ))
        .GlobalEnv$update_control_data_snapshot <- function() {
          data %>% feather::write_feather(control_file)
          cat(crayon::green(paste0("Updated control_data for ", table_name, " (", control_file, ", ", nrow(data), " rows)")))
        }
        stop("validation failed")
      }
    } else {
      cat(crayon::blue(paste0("Writing validation data for ", table_name, "...\n")))
      feather::write_feather(data, control_file)
    }
  }
}

drop_dependent_tables <- function (table_name)
  purrr::map(get_dependent_tables(table_name), ~ drop_table(.))

# NOTE: table_name must be in the sql_schema.R data structure
replace_table <- function (data, table_name) {
  validate_control_data(data, table_name)
  slow <- nrow(data) > 50000
  drop_dependent_tables(table_name)
  drop_table(table_name)
  db_execute(sql_schema[[table_name]]$create)
  timed_with_db_pool(
    paste0("dbWriteTable: ", table_name, " (", nrow(data), " rows)"),
    function (connection) RPostgres::dbWriteTable(connection, table_name, data, append = TRUE),
    slow = slow
  )
  for (sql in sql_schema[[table_name]]$addSchema) {
    iatlas.data::db_execute(sql, slow = slow)
  }
  data
}
