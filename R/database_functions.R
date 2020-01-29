# Database helper functions.

with_db_pool <- function(f) {
  connection <- pool::poolCheckout(.GlobalEnv$pool)
  on.exit(pool::poolReturn(connection))
  f(connection)
}

timed_with_db_pool <- function(context, f) {
  cat(paste0("START: ", context, "\n"))
  tictoc::tic(context)
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
    paste0("reset table using DELETE-FROM: ", table_name),
    function(connection) pool::dbSendQuery(connection, paste0("DELETE FROM ", table_name))
  )

table_exists <- function(table_name)
  with_db_pool(function(connection) pool::dbExistsTable(connection, table_name))

db_get_query <- function(query)
  with_db_pool(function(connection) pool::dbGetQuery(connection, query))

read_table <- function(table_name)
  timed_with_db_pool(
    paste0("read all records from `", table_name, "`"),
    function(connection) pool::dbReadTable(connection, table_name)
  )

drop_table <- function(table_name)
  db_execute(paste0("DROP TABLE IF EXISTS ", table_name))

db_execute <- function(query)
  timed_with_db_pool(
    paste0("dbExecute: ", query),
    function(connection) pool::dbExecute(connection, query)
  )

write_table_ts <- function(df, table_name) {
  tictoc::tic(paste0("write all records to `", table_name, "`"))
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

# NOTE: table_name must be in the sql_schema.R data structure
replace_table <- function (data, table_name) {
  drop_table(table_name)
  db_execute(sql_schema[[table_name]]$create)
  timed_with_db_pool(
    paste0("dbWriteTable ", table_name, " (", nrow(data), " rows)"),
    function (connection) RPostgres::dbWriteTable(connection, table_name, data, append = TRUE)
  )
  for (sql in sql_schema[[table_name]]$addSchema) {
    iatlas.data::db_execute(sql)
  }
  data
}
