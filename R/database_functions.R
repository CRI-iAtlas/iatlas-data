# Database helper functions.

with_db_pool <- function(f) {
  connection <- pool::poolCheckout(.GlobalEnv$pool)
  on.exit(pool::poolReturn(connection))
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

delete_rows <- function(table_name)
  timed_with_db_pool(
    paste0("dbSendQuery: DELETE-FROM ", table_name),
    function(connection) pool::dbSendQuery(connection, paste0("DELETE FROM ", table_name))
  )

table_exists <- function(table_name)
  with_db_pool(function(connection) pool::dbExistsTable(connection, table_name))

db_get_query <- function(query)
  with_db_pool(function(connection) pool::dbGetQuery(connection, query))

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

write_table_ts <- function(df, table_name) {
  validate_control_data(df, table_name)
  if (nrow(df) >= 100000) {
    cat(crayon::yellow(paste0("ATTENTION: The table '", table_name, "' should probably be created with replace_table, not write_table_ts")))
  }
  tictoc::tic(paste0("dbWriteTable: ", table_name, " (", nrow(df), " rows)"))
  result <- pool::poolWithTransaction(.GlobalEnv$pool, function(connection) {
    # Disable table_name's indexes.
    connection %>% pool::dbExecute(paste0(
      "UPDATE pg_index ",
      "SET indisready=false ",
      "WHERE indrelid = (",
      "SELECT oid ",
      "FROM pg_class ",
      "WHERE relname='", table_name, "'",
      ");"
    ))

    connection %>% pool::dbWriteTable(table_name, df, append = TRUE, copy = TRUE)

    # Re-enable table_name's indexes.
    connection %>% pool::dbExecute(paste0(
      "UPDATE pg_index ",
      "SET indisready=true ",
      "WHERE indrelid = (",
      "SELECT oid ",
      "FROM pg_class ",
      "WHERE relname='", table_name, "'",
      ");"
    ))

    # Reindex the table
    connection %>% pool::dbExecute(paste0("REINDEX TABLE ", table_name, ";"))
  })
  tictoc::toc()

  return(result)
}

validate_control_data <- function (data, table_name) {
  control_folder <- "./control_data/"
  control_file <- paste0(control_folder, table_name, ".feather")
  if (file.exists(control_folder)) {
    if (file.exists(control_file)) {
      cat(crayon::magenta(paste0("Validating data for ", table_name, " (", nrow(data), " rows)...\n")))
      if (dplyr::all_equal(feather::read_feather(control_file), data) == TRUE)
        cat(crayon::bold(crayon::green(paste0("PASS: control data for ", table_name, " is identical\n"))))
      else {
        cat(crayon::bold(crayon::red(paste0("FAIL: control data for ", table_name, " is different\n"))))
        stop("validation failed")
      }
    } else {
      cat(crayon::blue(paste0("Writing validation data for ", table_name, "...\n")))
      feather::write_feather(data, control_file)
    }
  }
}

# NOTE: table_name must be in the sql_schema.R data structure
replace_table <- function (data, table_name) {
  validate_control_data(data, table_name)
  slow <- nrow(data) > 50000
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
