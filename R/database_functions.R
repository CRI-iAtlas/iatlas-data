# Database helper functions.

with_db_pool <- function(f) {
  connection <- pool::poolCheckout(.GlobalEnv$pool)
  on.exit(pool::poolReturn(connection))
  f(connection)
}

timed_with_db_pool <- function(context, f) {
  tictoc::tic(context)
  on.exit(tictoc::toc())
  with_db_pool(f)
}

delete_rows <- function(table_name)
  with_db_pool(function(connection) pool::dbSendQuery(connection, paste0("DELETE FROM ", table_name)))

table_exists <- function(table_name)
  with_db_pool(function(connection) pool::dbExistsTable(connection, table_name))

db_get_query <- function(query)
  with_db_pool(function(connection) pool::dbGetQuery(connection, query))

read_table <- function(table_name)
  timed_with_db_pool(
    paste0("Time taken to read from the `", table_name, "` table in the DB"),
    function(connection) pool::dbReadTable(connection, table_name)
  )

write_table_ts <- function(df, table_name) {
  tictoc::tic(paste0("Time taken to write to the `", table_name, "` table in the DB"))
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
