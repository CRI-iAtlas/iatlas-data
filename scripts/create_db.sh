#!/bin/bash

YELLOW="\033[1;33m"
GREEN="\033[0;32m"
# No Color
NC='\033[0m'

# env can be dev or test. If no env argument is passed as the first argument (not dev or test), it will default to dev.
case $1 in
    dev | test)
        env=$1
    ;;

    *)
        env=dev
    ;;
esac

# If the first argument passed is create or reset, the DB and tables will be build, wiping out any existing DB and tables.
case $1 in
    create | reset)
        reset=true
    ;;

    *)
        # If an env argument is passed as the first argument and the second argument is create or reset, the DB and tables will be built, wiping out any existing DB and tables.
        case $2 in
            create | reset)
                reset=true
            ;;
            # By default, don't build the DB and tables.
            *)
                reset=false
            ;;
        esac
    ;;
esac

>&2 echo -e "${GREEN}Env == ${env}${NC}"
>&2 echo -e "${GREEN}Reset == ${reset}${NC}"

# The local project directory (assumes this file is stll in a child folder of the project).
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && cd ../ && pwd )"
>&2 echo -e "${GREEN}Current dir - ${DIR}${NC}"

docker_image="pg-docker"

create_db_sql="create_${env}_db.sql"
db_data_dir="$DIR/docker/volumes/postgres"
db_port=5432
db_user="postgres"
db_pw="docker"

if [ $reset == true ]; then
    >&2 echo -e "${GREEN}Postgres: up - building database and tables${NC}"

    # Copy the database SQL file into the docker container.
    # docker cp $DIR/sql/$create_db_sql $docker_image:/$create_db_sql
    # Copy the create enums SQL file into the docker container.
    # docker cp $DIR/sql/create_enums.sql $docker_image:/create_enums.sql

    >&2 echo -e "${YELLOW}Postgres: creating tables and indexes...${NC}"
    # Run the database SQL script within the docker container using the docker container's psql.
    # docker exec -u $db_user $docker_image psql -q -f //$create_db_sql
    PGPASSWORD=${db_pw} psql -h postgres -U ${db_user} -p ${db_port} -q -f /home/rstudio/sql/$create_db_sql

    >&2 echo -e "${GREEN}Postgres: created tables and indexes${NC}"
fi
