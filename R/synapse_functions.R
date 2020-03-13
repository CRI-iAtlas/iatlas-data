
create_global_synapse_connection <- function() {
  if (!iatlas.data::present(.GlobalEnv$synapse_connected)) {
    synapser::synLogin()
    .GlobalEnv$synapse_connected <- T
  } else {
    cat(crayon::green("Logged into Synapse\n"))
  }
}
