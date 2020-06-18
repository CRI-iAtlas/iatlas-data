# iAtlas Data Structures

When importing data into iAtlas, it is very imprtant that the following conventions are followed. Doing so will get the new data into the iAtlas database and make it available for the app.

## Data Model

Information on the data model can be found in the `data_model` folder which contains this [README.md](../data_model/README.md#iatlas-data-model) file.

## File Format

- feather files

  All data should come into the iAtlas application in the form of feather files. Feather files allow for fast reading and help ensure structural integrity.

## Data Locations

All data (feather files) should be located in the [`iAtlas Synapse directory`](https://www.synapse.org/#!Synapse:syn22123343)

Within the `feather_file` directory, data files should be segregated into folders as follows:

- [`copy_number_results`](#copy_number_results)
- [`datasets`](#datasets)
- [`driver_results`](#driver_results)
- [`edges`](#edges)
- [`features`](#features)
- [`gene_types`](#gene_types)
- [`genes`](#genes)
- [`mutation_codes`](#mutation_codes)
- [`mutation_types`](#mutation_types)
- [`mutations`](#mutations)
- [`nodes`](#nodes)
- [`patients`](#patients)
- [`publications`](#publications)
- [`relationships`](#relationships)
  - [`datasets_to_tags`](#datasets_to_tags)
  - [`features_to_samples`](#features_to_samples)
  - [`genes_to_samples`](#genes_to_samples)
  - [`genes_to_types`](#genes_to_types)
  - [`samples_to_mutations`](#samples_to_mutations)
  - [`samples_to_tags`](#samples_to_tags)
  - [`tags_to_tags`](#tags_to_tags)
- [`samples`](#samples)
- [`slides`](#slides)
- [`tags`](#tags)

## Feather File Structure

Data files in each folder MUST follow a specific convention for that data type. The files can be named as is deemed most descriptive and MUST end in `.feather`.

Column names MUST be spelled exactly as shown in this document.

The conventions for the feather files in each folder are as follows:

- ### `copy_number_results`

  #### Copy Number Results Column Names

  - _feature_

    The name of a feature. These unique names MUST exist in data in the `features` folder.

    type - _(character)_

  - _entrez_

    The entrez id of a gene. These genes MUST exist in data in the `genes` folder.

    type - _(numeric)_
  
  - _dataset_

    The name of a dataset. These unique names MUST exist in data in the `datasets` folder.
    
    type - _(character)_

  - _tag_

    The tag name associated with this copy number result. These tags MUST exist in data in the `tags` folder.

    type - _(character)_

  - _direction_

    The direction of this copy number result.

    type - _([DIRECTION_ENUM](../data_model/README.md#DIRECTION_ENUM))_

  - _mean_normal_

    The mean normal value this copy number result.

    type - _(numeric)_

  - _mean_cnv_

    The mean normal cnv this copy number result.

    type - _(numeric)_

  - _p_value_

    The p value associated with this copy number result.

    type - _(numeric)_

  - _log10_p_value_

    The log10 p value associated with this copy number result.

    type - _(numeric)_

  - _t_stat_

    The t stat value of this copy number result.

    type - _(numeric)_
    
  ### `datasets`

  #### Datasets Column Names

  - _name_

    The name of a the dataset. Must be unique, must not use any charcaters besides letters, number and underscores.
    
    type - _(character)_
  
  - _display_

    A display name for the dataset.
    
    type - _(character)_
    


  ### `driver_results`

  #### Driver Results Column Names

  - _feature_

    The name of a feature. These unique names MUST exist in data in the `features` folder.
    
    type - _(character)_
    
  - _dataset_

    The name of a dataset. These unique names MUST exist in data in the `datasets` folder.

    type - _(character)_

  - _entrez_

    The entrez id of a gene. These genes MUST exist in data in the `genes` folder.

    type - _(numeric)_

  - _mutation_code_

    The mutation code associated with this driver result. These mutation codes MUST exist in data in the `mutation_codes` folder.

    type - _(character)_

  - _tag_

    The tag name associated with this driver result. These tags MUST exist in data in the `tags` folder.

    type - _(character)_

  - _p_value_

    The p value associated with this driver result.

    type - _(numeric)_

  - _fold_change_

    The fold change value associated with this driver result.

    type - _(numeric)_

  - _log10_p_value_

    The log10 p value associated with this driver result.

    type - _(numeric)_

  - _log10_fold_change_

    The log10 fold change value associated with this driver result.

    type - _(numeric)_

  - _n_wt_

    The number of "Wild Type" genes associated with this driver result.

    type - _(integer)_

  - _n_mut_

    The number of "Mutant" genes associated with this driver result.

    type - _(integer)_

* ### `edges`

  #### Edges Column Names

  - _from_

    The node the edge is starting from. This may be either a gene id (Entrez - NCBI Id) or a feature name. These unique names MUST exist in data in either the `genes` folder or the `features` folder.

    type - _(character)_

  - _to_

    The node the edge is ending at. This may be either a gene id (Entrez - NCBI Id) or a feature name. These unique names MUST exist in data in either the `genes` folder or the `features` folder.

    type - _(character)_

  - _label_

    The label of the edge.

    type - _(character)_

  - _score_

    The numeric value of the edge.

    type - _(numeric)_

  - _tag_ (optional)

    The tag related to BOTH the from and to node. These tags MUST exist in data in the `tags` folder.\
    This column name and tag value MUST also exist in the _nodes_ data.

    type - _(character)_

  - _tag.XX_ (optional)

    Additional tags related to BOTH the from and to node. These tags MUST exist in data in the `tags` folder.\
    The column name MUST start with `tag` but may be followed by a dot (`.`) and some additional descriptive text. ie `tag.second` or `tag.01`. There may be as many tag columns as needed.\
    This column name and tag value MUST also exist in the _nodes_ data.

    type - _(character)_

* ### `features`

  #### Features Column Names

  - _name_

    The name of the feature.

    type - _(character)_

  - _display_

    A friendly display name for the feature.

    type - _(character)_

  - _class_

    The class of the feature. If the feature does not have a class, use `Miscellaneous`.

    type - _(character)_

  - _method_tag_ (optional)

    The method tag of the feature.

    type - _(character)_

  - _order_ (optional)

    The prefered order of priority for the feature.

    type - _(integer)_

  - _unit_ (optional)

    The unit used for the value of the feature.

    type - _([UNIT_ENUM](../data_model/README.md#UNIT_ENUM))_

* ### `gene_types`

  #### Gene Type Column Names

  - _name_

    The name of the gene type.

    type - _(character)_

  - _display_

    A friendly display name for the gene type.

    type - _(character)_

* ### `genes`

  #### Gene Column Names

  - _entrez_ (required)

    The entrez identifier of the gene. This is used through out the app to uniquely identify the gene. This is REQUIRED.

    type - _(numeric)_

  - _hgnc_

    The Hugo Id of the gene.

    type - _(character)_

  - _description_

    A description of the gene.

    type - _(character)_

  - _friendly_name_ (optional)

    A human friendly display name for the gene.

    type - _(character)_

  - _io_landscape_name_ (optional)

    The IO Landscape name for the gene.

    type - _(character)_

  - _gene_family_ (optional)

    The gene family of the gene.

    type - _(character)_

  - _gene_function_ (optional)

    The gene function of the gene.

    type - _(character)_

  - _immune_checkpoint_ (optional)

    The immune checkpoint for the gene.

    type - _(character)_

  - _node_type_ (optional)

    The node type of the gene.

    type - _(character)_

  - _pathway_ (optional)

    The pathway of the gene.

    type - _(character)_

  - _super_category_ (optional)

    The super category of the gene.

    type - _(character)_

  - _therapy_type_ (optional)

    The therapy type of the gene.

    type - _(character)_

* ### `mutation_codes`

  #### Mutation Code Column Names

  - _code_

    The mutation code. This is REQUIRED.

    type - _(character)_

* ### `mutation_types`

  #### Mutation Type Column Names

  - _name_

    The name of the mutation type.

    type - _(character)_

  - _display_

    A friendly display name for the mutation type.

    type - _(character)_

* ### `mutations`

  #### Mutation Column Names

  - _entrez_ (required)

    The entrez id of a gene. These genes MUST exist in data in the `genes` folder.

    type - _(numeric)_

  - _mutation_code_ (required)

    The code (name) of a mutation code. These mutation codes MUST exist in data in the `mutation_codes` folder.

    type - _(character)_

  - _mutation_type_

    The name of a mutation type. These mutation types MUST exist in data in the `mutation_types` folder.

    type - _(character)_

* ### `nodes`

  #### Node Column Names

  A node may use a gene OR a feature. One of these is REQUIRED.

  - _entrez_

    The entrez id of a gene. These genes MUST exist in data in the `genes` folder.

    type - _(numeric)_
    
  - _dataset_

    The name of a dataset. These unique names MUST exist in data in the `datasets` folder.
    
    type - _(character)_

  - _feature_

    The name of the feature. These features MUST exist in data in the `features` folder.

    type - _(character)_

  - _label_

    The label of the edge.

    type - _(character)_

  - _score_

    The numeric value of the node.

    type - _(numeric)_
  
  - _network_ 

    The network tag related to the node. These tags MUST exist in data in the `tags` folder.\
    
    type - _(character)_

  - _tag_ (optional)

    The a tag related to the node. These tags MUST exist in data in the `tags` folder.\
    For a node to be used in edges, this column name MUST also exist in the _edges_ data.

    type - _(character)_

  - _tag.XX_ (optional)

    Additional tags related to the node. These tags MUST exist in data in the `tags` folder.\
    The column name MUST start with `tag` but may be followed by a dot (`.`) and some additional descriptive text. ie `tag.second` or `tag.01`. There may be as many tag columns as needed.\
    This column name MUST also exist in the _nodes_ data.

    type - _(character)_

* ### `patients`

  #### Patients Column Names

  - _barcode_

    The unique identifier representing a patient.

    type - _(character)_

  - _age_ (optional)

    The age of the patient.

    type - _(character)_

  - _ethinicity_ (optional)

    The ethinicity of the patient.

    type - _(character)_

  - _gender_ (optional)

    The gender of the patient.

    type - _(character)_

  - _height_ (optional)

    The height of the patient.

    type - _(character)_

  - _race_ (optional)

    The race of the patient.

    type - _(character)_

  - _weight_ (optional)

    The weight of the patient.

    type - _(character)_

* ### `samples`

  #### Sample Column Names

  - _name_

    The unique identifier representing the sample.

    type - _(character)_

  - _patient_barcode_

    The unique identifier representing a patient related to the sample. The patient MUST exist in the data in the `patients` folder.

    type - _(character)_

  - _dataset_

    The name of a the dataset. These unique names MUST exist in data in the `datasets` folder.
    
    type - _(character)_
  

* ### `slides`

  #### Slide Column Names

  - _name_

    The unique identifier representing the slide.

    type - _(character)_

  - _patient_barcode_

    The unique identifier representing a patient related to the slide. The patient MUST exist in the data in the `patients` folder.

    type - _(character)_

* ### `tags`

  #### Tag Column Names

  Tags may be used to group various pieces of data. At a base level, a tag is simply a string (with some descriptive meta data). Multpile pieces of data may be related by tagging them. Tags may even be tagged to create the semblance of hierarchy.

  - _name_

    The unique identifying name of the tag.

    type - _(character)_

  - _characteristics_

    Any identifying characteristics of the tag.

    type - _(character)_

  - _display_

    A human friendy display name for the tag.

    type - _(character)_

  - _color_

    A specific hex value to represent the tag by color.

    type - _(character)_

* ### `publications`

  #### Publications Column Names

  - _pubmed_id_

    The unique id at "https://pubmed.ncbi.nlm.nih.gov/{id}"

    type - _(integer)_
  
  - _journal_

    The journal published in

    type - _(character)_
    
  - _first_author_last_name_

    The last name of the first author

    type - _(character)_
  
  - _year_

    The year published

    type - _(integer)_
    
  - _title_

    The name of the publication

    type - _(character)_

* ### `relationships`

  Often data is about relationships. The following folders are for data relationships. Each relationship depends on the original dat pieces being represented in their respective folders.

  - ### `publications_to_genes`

    #### Publications To Genes Column Names  
    
    - _pubmed_id_

      The pubmed id of the publication. These unique ids MUST exist in data in the `publications` folder.
    
      type - _(integer)_
  
    - _entrez_

      The entrez id of the gene. These unique ids MUST exist in data in the `genes` folder.
    
      type - _(integer)_
  
  - ### `datasets_to_tags`

    #### Datasets To Tags Column Names

    - _dataset_

      The name of a the dataset. These unique names MUST exist in data in the `datasets` folder.
    
      type - _(character)_
  
    - _tag_

      The name of the tag. These unique names MUST exist in data in the `tags` folder.
    
      type - _(character)_

  - #### `features_to_samples`

    ##### Feature to Sample Column Names

    - _feature_

      The name of the feature. These features MUST exist in data in the `features` folder.

      type - _(character)_

    - _sample_

      The name of the sample. These samples MUST exist in data in the `samples` folder.

      type - _(character)_

    - _value_

      The numeric value of the feature to sample relationship. The unit of the value is expressed in the [features](#features) data.

    type - _(numeric)_

  - #### `genes_to_samples`

    ##### Gene to Sample Column Names

    - _entrez_

      The entrez id of a gene. These genes MUST exist in data in the `genes` folder.

      type - _(numeric)_

    - _sample_

      The name of the sample. These samples MUST exist in data in the `samples` folder.

      type - _(character)_

    - _rna_seq_expr_

      The unique numeric RNA sequence expression of the relationship between the gene and the sample.

      type - _(numeric)_

  - #### `genes_to_types`

    ##### Gene to Gene Type Column Names

    - _entrez_

      The entrez id of a gene. These genes MUST exist in data in the `genes` folder.

      type - _(numeric)_

    - _gene_type_

      The type of gene this specific gene is related to. These gene types MUST exist in data in the `gene_types` folder.

      type - _(character)_

  - #### `samples_to_mutations`

    ##### Sample to Mutation Code Column Names

    - _sample_ (required)

      The name of the sample. These samples MUST exist in data in the `samples` folder.

      type - _(character)_

    - _entrez_ (required)

      The entrez id of a gene. These genes MUST exist in data in the `genes` folder.

      type - _(numeric)_

    - _mutation_code_ (optional - may be NA)

      The code (name) of the mutation code. These mutation codes MUST exist in data in the `mutation_codes` folder.

      type - _(character)_

    - _mutation_type_ (optional - may be NA)

      The name of the mutation type. These mutation types MUST exist in data in the `mutation_types` folder.

      type - _(character)_

    - _status_

      The status of the gene in this psecific relationship. My be `Wt` (Wild Type) or `Mut` (Mutant).

      type - _([STATUS_ENUM](../data_model/README.md#status_ENUM))_

  - #### `samples_to_tags`

    ##### Sample to Tag Column Names

    - _sample_

      The name of the sample. These samples MUST exist in data in the `samples` folder.

      type - _(character)_

    - _tag_

      The tag related to the sample. These tags MUST exist in data in the `tags` folder.

      type - _(character)_

  - #### `tags_to_tags`

    ##### Tag to Tag Column Names

    - _tag_

      The name of the tag. These tags MUST exist in data in the `tags` folder.

      type - _(character)_

    - _related_tag_

      The tag related to the initial tag. These tags MUST exist in data in the `tags` folder.

      type - _(character)_
