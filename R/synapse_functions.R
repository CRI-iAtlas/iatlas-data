synapse_logout <- function(){
  if (!iatlas.data::present(.GlobalEnv$synapse)) {
    .GlobalEnv$synapse$logout()
    rm(synapse, pos = .GlobalEnv)
  }
}


create_global_synapse_connection <- function() {
  if (!iatlas.data::present(.GlobalEnv$synapse)) {
    synapse <- reticulate::import("synapseclient")
    syn <- synapse$Synapse()
    syn$login()
    .GlobalEnv$synapse <- syn
  }
  cat(crayon::green("Logged into Synapse\n"))
  return(.GlobalEnv$synapse)
}
