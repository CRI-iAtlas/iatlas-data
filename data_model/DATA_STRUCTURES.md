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

- `edges`
- `features`
- `genes`
- `nodes`
- `patients`
- `relationships`
  - `features_to_samples`
  - `genes_to_samples`
  - `nodes_to_tags`
  - `samples_to_tags`
  - `tags_to_tags`
- `results`
- `samples`
- `tags`
