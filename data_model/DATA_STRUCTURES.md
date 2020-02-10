# iAtlas Data Structures

<span style="color: red; font: normal 1.4rem/1 arial">**Please Note:** This file is a work in progress. Please do not reference this file until this warning has been removed.</span>

When importing data into iAtlas, it is very imprtant that the following conventions are followed. Doing so will get the new data into the iAtlas database and make it available for the app.

## Data Model

Information on the data model can be found in the `data_model` folder which contains this [README.md](README.md#iatlas-data-model) file.

## File Format

- feather files

  All data should come into the iAtlas application in the form of feather files. Feather files allow for fast reading and help ensure structural integrity.

## Data Locations

All data (feather files) should be located in the `feather_file` folder.

Within the `feather_file` folder, data files should be segregated as follows:

- `driver_results`
- `edges`
- `features`
- `gene_types`
- `genes`
- `mutation_codes`
- `nodes`
- `patients`
- `relationships`
  - `features_to_samples`
  - `genes_samples_mutations`
  - `genes_to_samples`
  - `genes_to_types`
  - `mutation_codes_to_gene_types`
  - `samples_to_tags`
  - `tags_to_tags`
- `samples`
- `slides`
- `tags`

## Feather File Structure

Data files in each folder MUST follow a specific convention for that data type. The conventions for each folder are as follows:

- ### `driver_results`

  #### Driver Results Column names

  Column names MUST be spelled exactly as shown in this document.

  - _feature_

    The name of a feature. These unique names MUST exist in data in the `features` folder.

  - _entrez_

    The entrez id of a gene. These genes MUST exist in data in the `genes` folder.

  - _hgnc_ (optional)

    The HGNC or Hugo id of a gene. These genes MUST exist in data in the `genes` folder.

  - _tag_

    The tag name associated with this driver result. These tags MUST exist in data in the `tags` folder.

  - _p_value_

    The p value associated with this driver result.

  - _fold_change_

    The fold change value associated with this driver result.

  - _log10_p_value_

    The log10 p value associated with this driver result.

  - _log10_fold_change_

    The log10 fold change value associated with this driver result.

  - _n_wt_

    The number of "Wild Type" genes associated with this driver result.

  - _n_mut_

    The number of "Mutant" genes associated with this driver result.
