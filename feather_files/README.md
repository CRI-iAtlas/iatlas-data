# iAtlas Data Structures

When importing data into iAtlas, it is very imprtant that the following conventions are followed. Doing so will get the new data into the iAtlas database and make it available for the app.

## Data Model

Information on the data model can be found in the `data_model` folder which contains this [README.md](../data_model/README.md#iatlas-data-model) file.

## File Format

- feather files

  All data should come into the iAtlas application in the form of feather files. Feather files allow for fast reading and help ensure structural integrity.

## Data Locations

All data (feather files) should be located in the `feather_file` folder.

Within the `feather_file` folder, data files should be segregated into folders as follows:

- `driver_results`
- `edges`
- `features`
- `gene_types`
- `genes`
- `mutation_codes`
- `mutation_types`
- `mutations`
- `nodes`
- `patients`
- `relationships`
  - `edges_to_tags`
  - `features_to_samples`
  - `genes_to_samples`
  - `genes_to_types`
  - `samples_to_mutations`
  - `samples_to_tags`
  - `tags_to_tags`
- `samples`
- `slides`
- `tags`

## Feather File Structure

Data files in each folder MUST follow a specific convention for that data type. The files can be named as is deemed most descriptive and MUST end in `.feather`.

Column names MUST be spelled exactly as shown in this document.

The conventions for the feather files in each folder are as follows:

- ### `driver_results`

  #### Driver Results Column Names

  - _feature_

    The name of a feature. These unique names MUST exist in data in the `features` folder.

  - _entrez_

    The entrez id of a gene. These genes MUST exist in data in the `genes` folder.

  - _mutation_code_

    The mutation code associated with this driver result. These mutation codes MUST exist in data in the `mutation_codes` folder.

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

- ### `edges`

  #### Edges Column Names

  - _from_

    The node the edge is starting from. This may be either a gene id (Entrez - NCBI Id) or a feature name. These unique names MUST exist in data in either the `genes` folder or the `features` folder.

  - _to_

    The node the edge is ending at. This may be either a gene id (Entrez - NCBI Id) or a feature name. These unique names MUST exist in data in either the `genes` folder or the `features` folder.

  - _score_

    The numeric value of the edge.

  - _tag_ (optional)

    The tag related to BOTH the from and to node. These tags MUST exist in data in the `tags` folder.\
    This column name and tag value MUST also exist in the _nodes_ data.

  - _tag.XX_ (optional)

    Additional tags related to BOTH the from and to node. These tags MUST exist in data in the `tags` folder.\
    The column name MUST start with `tag` but may be followed by a dot (`.`) and some additional descriptive text. ie `tag.second` or `tag.01`. There may be as many tag columns as needed.\
    This column name and tag value MUST also exist in the _nodes_ data.

- ### `features`

  #### Features Column Names

  - _name_

    The name of the feature.

  - _display_

    A friendly display name for the feature.

  - _class_

    The class of the feature. If the feature does not have a class, use `Miscellaneous`.

  - _method_tag_ (optional)

    The method tag of the feature.

  - _order_ (optional)

    The prefered order of priority for the feature.

  - _unit_ (optional)

    The unit used for the value of the feature.

- ### `gene_types`

  #### Gene Type Column Names

  - _name_

    The name of the gene type.

  - _display_

    A friendly display name for the gene type.

- ### `genes`

  #### Gene Column Names

  - _entrez_ (required)

    The entrez identifier of the gene. This is used through out the app to uniquely identify the gene. This is REQUIRED.

  - _hgnc_

    The Hugo Id of the gene.

  - _description_

    A description of the gene.

  - _friendly_name_ (optional)

    A human friendly display name for the gene.

  - _io_landscape_name_ (optional)

    The IO Landscape name for the gene.

  - _gene_family_ (optional)

    The gene family of the gene.

  - _gene_function_ (optional)

    The gene function of the gene.

  - _immune_checkpoint_ (optional)

    The immune checkpoint for the gene.

  - _node_type_ (optional)

    The node type of the gene.

  - _pathway_ (optional)

    The pathway of the gene.

  - _super_category_ (optional)

    The super category of the gene.

  - _therapy_type_ (optional)

    The therapy type of the gene.

  - _references_ (optional)

    URL references for the gene. This MUST be formatted as comma separated URLs inside curly braces -ie:\
    multiple references -> `{http://some-reference-url,https://another-reference-url}`\
    single reference -> `{http://some-reference-url}`

- ### `mutation_codes`

  #### Mutation Code Column Names

  - _code_

    The mutation code. This is REQUIRED.

- ### `mutation_types`

  #### Mutation Type Column Names

  - _name_

    The name of the mutation type.

  - _display_

    A friendly display name for the mutation type.

- ### `mutations`

  #### Mutation Column Names

  - _entrez_ (required)

    The entrez id of a gene. These genes MUST exist in data in the `genes` folder.

  - _mutation_code_ (required)

    The code (name) of a mutation code. These mutation codes MUST exist in data in the `mutation_codes` folder.

  - _mutation_type_

    The name of a mutation type. These mutation types MUST exist in data in the `mutation_types` folder.

- ### `nodes`

  #### Node Column Names

  A node may use a gene OR a feature. One of these is REQUIRED.

  - _entrez_

    The entrez id of a gene. These genes MUST exist in data in the `genes` folder.

  - _feature_

    The name of the feature. These features MUST exist in data in the `features` folder.

  - _score_

    The numeric value of the node.

  - _tag_ (optional)

    The a tag related to the node. These tags MUST exist in data in the `tags` folder.\
    For a node to be used in edges, this column name MUST also exist in the _edges_ data.

  - _tag.XX_ (optional)

    Additional tags related to the node. These tags MUST exist in data in the `tags` folder.\
    The column name MUST start with `tag` but may be followed by a dot (`.`) and some additional descriptive text. ie `tag.second` or `tag.01`. There may be as many tag columns as needed.\
    This column name MUST also exist in the _nodes_ data.

- ### `patients`

  #### Patients Column Names

  - _barcode_

    The unique identifier representing a patient.

  - _age_ (optional)

    The age of the patient.

  - _ethinicity_ (optional)

    The ethinicity of the patient.

  - _gender_ (optional)

    The gender of the patient.

  - _height_ (optional)

    The height of the patient.

  - _race_ (optional)

    The race of the patient.

  - _weight_ (optional)

    The weight of the patient.

- ### `samples`

  #### Sample Column Names

  - _name_

    The unique identifier representing the sample.

  - _patient_barcode_

    The unique identifier representing a patient related to the sample. The patient MUST exist in the data in the `patients` folder.

- ### `slides`

  #### Slide Column Names

  - _name_

    The unique identifier representing the slide.

  - _patient_barcode_

    The unique identifier representing a patient related to the slide. The patient MUST exist in the data in the `patients` folder.

- ### `tags`

  #### Tag Column Names

  Tags may be used to group various pieces of data. At a base level, a tag is simply a string (with some descriptive meta data). Multpile pieces of data may be related by tagging them. Tags may even be tagged to create the semblance of hierarchy.

  - _name_

    The unique identifying name of the tag.

  - _characteristics_

    Any identifying characteristics of the tag.

  - _display_

    A human friendy display name for the tag.

  - _color_

    A specific hex value to represent the tag by color.

- ### `relationships`

  Often data is about relationships. The following folders are for data relationships. Each relationship depends on the original dat pieces being represented in their respective folders.

  - #### `features_to_samples`

    ##### Feature to Sample Column Names

    - _feature_

      The name of the feature. These features MUST exist in data in the `features` folder.

    - _sample_

      The name of the sample. These samples MUST exist in data in the `samples` folder.

    - _value_

      The numeric value of the feature to sample relationship. The unit of the value is expressed in the [features](#features) data.

  - #### `genes_to_samples`

    ##### Gene to Sample Column Names

    - _entrez_

      The entrez id of a gene. These genes MUST exist in data in the `genes` folder.

    - _sample_

      The name of the sample. These samples MUST exist in data in the `samples` folder.

    - _rna_seq_expr_

      The unique numeric RNA sequence expression of the relationship between the gene and the sample.

  - #### `genes_to_types`

    ##### Gene to Gene Type Column Names

    - _entrez_

      The entrez id of a gene. These genes MUST exist in data in the `genes` folder.

    - _gene_type_

      The type of gene this specific gene is related to. These gene types MUST exist in data in the `gene_types` folder.

  - #### `samples_to_mutations`

    (This is DEPRECATED. Please do not populate this relationsship.)

    ##### Sample to Mutation Code Column Names

    - _sample_ (required)

      The name of the sample. These samples MUST exist in data in the `samples` folder.

    - _entrez_ (required)

      The entrez id of a gene. These genes MUST exist in data in the `genes` folder.

    - _mutation_code_ (optional - may be NA)

      The code (name) of the mutation code. These mutation codes MUST exist in data in the `mutation_codes` folder.

    - _mutation_type_ (optional - may be NA)

      The name of the mutation type. These mutation types MUST exist in data in the `mutation_types` folder.

    - _status_

      The status of the gene in this psecific relationship. My be `Wt` (Wild Type) or `Mut` (Mutant).

  - #### `samples_to_tags`

    ##### Sample to Tag Column Names

    - _sample_

      The name of the sample. These samples MUST exist in data in the `samples` folder.

    - _tag_

      The tag related to the sample. These tags MUST exist in data in the `tags` folder.

  - #### `tags_to_tags`

    ##### Tag to Tag Column Names

    - _tag_

      The name of the tag. These tags MUST exist in data in the `tags` folder.

    - _related_tag_

      The tag related to the initial tag. These tags MUST exist in data in the `tags` folder.
