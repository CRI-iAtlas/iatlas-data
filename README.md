# sage-iatlas-data

Data for the iAtlas app.

Shiny-iAtlas is an interactive web portal that provides multiple analysis modules to visualize and explore immune response characterizations across cancer types. The app is hosted on shinyapps.io at [https://isb-cgc.shinyapps.io/shiny-iatlas/](https://isb-cgc.shinyapps.io/shiny-iatlas/) and can also be accessed via the main CRI iAtlas page at [http://www.cri-iatlas.org/](http://www.cri-iatlas.org/).

## Install

### Install Core Apps and System libraries

- R: [https://www.r-project.org/](https://www.r-project.org/) - v3.6.2

- RStudio: [https://rstudio.com/products/rstudio/download/](https://rstudio.com/products/rstudio/download/)

- Docker: [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)

  Ensure that the location of the repository is shared via docker:

  - Mac: [https://docs.docker.com/docker-for-mac/#file-sharing](https://docs.docker.com/docker-for-mac/#file-sharing)

  - Windows: [https://docs.microsoft.com/en-us/archive/blogs/stevelasker/configuring-docker-for-windows-volumes](https://docs.microsoft.com/en-us/archive/blogs/stevelasker/configuring-docker-for-windows-volumes)

- git-lfs: [https://git-lfs.github.com/](https://git-lfs.github.com/)

  Some feather files are _very_ large. `git-lfs` is used to store these files.

### Initialize R Packages and builds the Database

To build the database locally:

1. Clone this repository

1. Open `iatlas-data.Rproj`

1. Build the database locally with the following:

   1. Build the database by executing the following in the R console:

      ```R
      build_iatlas_db(reset = "reset")
      ```

   The databse should now be available on `localhost:5432`. The database is called `iatlas_dev`.

## Data

### Data Model

Information on the data model can be found in the `data_model` folder which contains this [README.md](data_model/README.md#iatlas-data-model) file.

### Data Structure

Information on the data structure can be found in the `data_model` folder which contains this [DATA_STRUCTURES.md](data_model/DATA_STRUCTURES.md#iatlas-data-structures) markdown file.

### Data Sources

Input data for the Shiny-iAtlas portal was accessed from multiple remote sources, including **Synapse**, the **ISB Cancer Genomics Cloud**, and **Google Drive**. The feather files derived from this data and used to populate the database are stored in the `feather_files` folder:

- `edges >`
  - `edges_TCGAImmune.feather`
  - `edges_TCGAStudy_Immune.feather`
  - `edges_TCGAStudy.feather`
  - `edges_TCGASubtype.feather`
- `features >`
- `gene_ids.feather`
- `genes >`
  - `driver_mutation_genes.feather`
  - `driver_mutation_genes.feather`
  - `immunomodulator_genes.feather`
  - `io_target_genes.feather`
- `nodes >`
  - `nodes_TCGAImmune.feather`
  - `nodes_TCGAStudy_Immune.feather`
  - `nodes_TCGAStudy.feather`
  - `nodes_TCGASubtype.feather`
- `patients >`
- `relationships >`
  - `features_to_samples >`
  - `genes_to_samples >`
  - `nodes_to_tags >`
  - `samples_to_tags >`
  - `tags_to_tags >`
- `results >`
- `samples >`
  - `immune_subtype_samples.feather`
  - `tcga_study_samples.feather`
  - `tcga_subtype_samples.feather`
- `SQLite_data >`
  - `driver_mutations1.feather`
  - `driver_mutations2.feather`
  - `driver_mutations3.feather`
  - `driver_mutations4.feather`
  - `driver_mutations5.feather`
  - `driver_results1.feather`
  - `driver_results2.feather`
  - `feature_values_long.feather`
  - `features.feather`
  - `groups.feather`
  - `immunomodulator_expr.feather`
  - `immunomodulators.feather`
  - `io_target_expr1.feather`
  - `io_target_expr2.feather`
  - `io_target_expr3.feather`
  - `io_target_expr4.feather`
  - `io_targets.feather`
  - `til_image_links.feather`
- `tags >`
