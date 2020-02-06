# Global function that may be used to spin-up, create, or reset the Postgres DB.
# env may be "prod", "dev", "test", or NULL. If NULL is passed, it will default to dev.
# If "prod" is passed as the env argument, the shell script will NOT be executed.
# reset may be "create", "reset", or NULL. If NULL is passed, it won't rebuild the DB and tables.
# NOTE: If "create" or "reset" are passed, the DB and tables will be built, wiping out any existing DB and tables.
create_db <- function(env = "dev", reset = NULL, script_path = 'scripts') {
  if (env != "prod") {
    system(paste(
      "bash",
      paste0(script_path, "/create_db.sh"),
      env,
      reset,
      sep = " "
    ))
  }
}
