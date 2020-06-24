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

synapse_store_feather_file <- function(df, file_name, parent_id){
  res <- feather::write_feather(df, file_name)
  iatlas.data::synapse_store_file(file_name, parent_id)
  file.remove(file_name)
  return(res)
}

synapse_store_file <- function(file, parent_id) {
  create_global_synapse_connection()
  file_entity <- .GlobalEnv$syn$File(file, parent_id)
  .GlobalEnv$synapse$store(file_entity)
}

synapse_read_all_feather_files <- function(parent_id) {
  create_global_synapse_connection()
  parent_id %>%
    .GlobalEnv$synapse$getChildren() %>%
    reticulate::iterate(.) %>%
    purrr::map_chr(purrr::pluck, "id") %>%
    purrr::map(.GlobalEnv$synapse$get) %>%
    purrr::map(purrr::pluck("path")) %>%
    purrr::map(feather::read_feather) %>%
    dplyr::bind_rows()
}

synapse_read_feather_file <- function(id) {
  create_global_synapse_connection()
  id %>%
    .GlobalEnv$synapse$get() %>%
    purrr::pluck("path") %>%
    feather::read_feather(.)
}
