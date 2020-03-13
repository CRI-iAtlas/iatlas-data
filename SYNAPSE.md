# SYNAPSE

The iAtlas Data may depend on data from Synapse. This uses synapseclient via reticulate. The following are steps to ensure it is installed and working.

## Dependencies

- [Python](https://www.python.org/) - version < 3.7
- [Miniconda](https://docs.conda.io/en/latest/miniconda.html)

## Reticulate

Reticulate should enstall as a part of the renv dependencies.

As reticulate installs, it should have a prompt that asks if you want to install miniconda. Select "Yes"

When miniconda installation finishes, you will be asked to activate the miniconda environment (from terminal)

```console
foo@bar:~$ conda activate r-reticulate
```

## Synapseclient

If the following error comes up:

```R
Error in py_module_import(module, convert = convert) :
  ModuleNotFoundError: No module named 'synapseclient'
```

Use these steps to resolve it:

To be continued....
