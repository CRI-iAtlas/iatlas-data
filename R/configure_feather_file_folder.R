# Specify where to find all the feather files for loading the data.
# NOTE: Used both in dev/prod as well as testing.
set_feather_file_folder <- function(feather_file_folder) .GlobalEnv$feather_file_folder <- feather_file_folder
get_feather_file_folder <- function() .GlobalEnv$feather_file_folder
