get_tcga_cytokine_nodes_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "tcga_cytokine_nodes_synapse",
    iatlas.data::get_tcga_cytokine_nodes()
  )
}

get_tcga_cytokine_edges_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "tcga_cytokine_edges_synapse",
    iatlas.data::get_tcga_cytokine_edges()
  )
}

get_cellimage_nodes_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "tcga_cellimage_nodes_synapse",
    iatlas.data::get_tcga_cellimage_nodes()
  )
}

get_cellimage_edges_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "tcga_cellimage_edges_synapse",
    iatlas.data::get_tcga_cellimage_edges()
  )
}

get_tcga_copynumber_results_cached <- function(){
  iatlas.data::create_global_synapse_connection()
  iatlas.data::result_cached(
    "tcga_copynumber_results_synapse",
    iatlas.data::get_tcga_copynumber_results()
  )
}
