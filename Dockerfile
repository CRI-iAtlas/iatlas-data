ARG R_VERSION
FROM r-base:${R_VERSION}

RUN mkdir -p /home/gitlab/sage-iatlas-data
WORKDIR /home/gitlab/sage-iatlas-data
COPY renv.lock .
COPY renv/activate.R renv/activate.R

# Install supporting packages
RUN apt-get -y update && apt-get -y install libpq-dev postgresql-client-12 libcurl4-openssl-dev libssl-dev libxml2-dev wget

# Resolve dependencies
ENV DOCKERBUILD 1
RUN R -e "source(\"renv/activate.R\"); renv::restore()"