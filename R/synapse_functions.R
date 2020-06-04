attempt_instantiate <- function() {
  if (reticulate::py_module_available("synapseclient")) {
    synapse <- reticulate::import("synapseclient")
    return(synapse)
  }
  cat(crayon::red("synapseclient unavailable!\n"))
  return(NULL)
}

create_global_synapse_connection <- function() {
  if (!iatlas.data::present(.GlobalEnv$syn)) {
    syn <- iatlas.data::attempt_instantiate()
    synapse <- syn$Synapse()
    if (!is.null(synapse) & is.null(synapse$username)) {
      synapse$login()
    } else if (is.null(synapse)) {
      cat(crayon::green("NOT Logged into Synapse\n"))
      return(NA)
    }
    .GlobalEnv$syn <- syn
    .GlobalEnv$synapse <- synapse
    cat(crayon::green("Logged into Synapse\n"))
  } else {
    cat(crayon::green("Already logged into Synapse\n"))
  }
  return(.GlobalEnv$synapse)
}

synapse_logout <- function() {
  if (iatlas.data::present(.GlobalEnv$synapse)) {
    .GlobalEnv$synapse$logout()
    rm(synapse, pos = ".GlobalEnv")
  }
  cat(crayon::green("Logged out of Synapse\n"))
  return(NULL)
}

synapse_store_file <- function(file, parent_id) {
  file_entity <- .GlobalEnv$syn$File(file, parent_id)
  .GlobalEnv$synapse$store(file_entity)
}
