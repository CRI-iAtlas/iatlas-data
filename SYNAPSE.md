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

If `conda activate r-reticulate` is unable to locate the environment:

1. In the R console: use conda_list() to get the list of current conda environments

   ```R
   reticulate::conda_list()
   ```

1. Look for the "r-reticulate" environment path, should look like:

   ```dataframe
   /<path-to-the-project-folder>/renv/python/r-reticulate/bin/python
   ```

1. Copy the env folder path of "r-reticulate" (note: leave off the `/bin/python`):

   ```dataframe
   /<path-to-the-project-folder>/renv/python/r-reticulate
   ```

1. Activate the r-reticulate environment:

   ```console
   foo@bar:~$ conda activate /<path-to-the-project-folder>/renv/python/r-reticulate
   ```

1. Inside the r-reticulate environment now, run:

```console
(/<path-to-the-project-folder>/renv/python/r-reticulate)@user:~$ pip install synapseclient
```

1. The previous error should now be gone.

## Synapseclient Credentials

For the login to Synapse to work correctly, there must be a `.synapseCofig` file in your user directory. An example file is located in the root of the application. Please see [https://python-docs.synapse.org/build/html/Credentials.html](https://python-docs.synapse.org/build/html/Credentials.html) for more details.
