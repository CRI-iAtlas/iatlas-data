# sage-iatlas-data

Data for the iAtlas app.

Shiny-iAtlas is an interactive web portal that provides multiple analysis modules to visualize and explore immune response characterizations across cancer types. The app is hosted on shinyapps.io at [https://isb-cgc.shinyapps.io/shiny-iatlas/](https://isb-cgc.shinyapps.io/shiny-iatlas/) and can also be accessed via the main CRI iAtlas page at [http://www.cri-iatlas.org/](http://www.cri-iatlas.org/).

## Install

### Install Core Apps and System libraries

- R: [https://www.r-project.org/](https://www.r-project.org/) - v3.6.2

- RStudio: [https://rstudio.com/products/rstudio/download/](https://rstudio.com/products/rstudio/download/)

- Docker: [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)

### Initialize R Packages, Database and run App

To build the database locally:

1. Clone this repository

1. Open `sage-iatlas-data.Rproj`

1. Build the database locally with the following:

   1. Make the database function available by executing the following in the R console:

      ```R
      source("iatlas_db.R")
      ```

   1. Build the database by executing the following in the R console:

      ```R
      build_iatlas_db(reset = "reset")
      ```

   The databse should now be available on `localhost:5432`. The database is called `iatlas_dev`.
