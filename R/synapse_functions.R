attempt_instantiate <- function() {
  if (reticulate::py_module_available("synapseclient")) {
    synapse <- reticulate::import("synapseclient")
    return(synapse$Synapse())
  }
  cat(crayon::red("synapseclient unavailable!\n"))
  return(NULL)
}

create_global_synapse_connection <- function() {
  if (!iatlas.data::present(.GlobalEnv$synapse)) {
    syn <- iatlas.data::attempt_instantiate()
    if (!is.null(syn) & is.null(syn$username)) {
      syn$login()
    } else if (is.null(syn)) {
      cat(crayon::green("NOT Logged into Synapse\n"))
      return(NA)
    }
    .GlobalEnv$synapse <- syn
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
