#!/bin/bash

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[1;31m'
# No Color
NC='\033[0m'

BACKUP_FILE_PATH="${CI_PROJECT_DIR}/iatlas_dev.pgdata"

if [[ $# -ne 4 ]]; then
    >&2 echo -e "${RED}[ERROR}: The build script requires for arguments: <db_host> <db_user> <db_passwd> <db_name>${NC}"
    exit 1
elif [[ ! -s ${BACKUP_FILE_PATH} ]]; then
    >&2 echo -e "${RED}[ERROR}: DB backup file at ${BACKUP_FILE_PATH} needs to exist and not be empty."
    exit 1
else
    DB_HOST=$1
    DB_USER=$2
    DB_PASSWORD=$3
    TARGET_DB=$4
    NEW_DB=${TARGET_DB}_`date +"%s"`

    # Make the new temporary DB
    >&2 echo -e "${GREEN}Creating new target DB @ ${DB_HOST}/postgres${NC}"
    PGPASSWORD=${DB_PASSWORD} psql -U postgres -h $DB_HOST  -c"CREATE DATABASE ${NEW_DB}"
    >&2 echo -e "${GREEN}Restoring to DB @ ${DB_HOST}/${NEW_DB}${NC}"
    PGPASSWORD=${DB_PASSWORD} pg_restore -v -h ${DB_HOST} -U ${DB_USER} -d ${NEW_DB} -h /tmp/iatlas_dev.pgdata
    >&2 echo -e "${GREEN}Swapping new and target DB @ ${DB_HOST}/postgres${NC}"
    PGPASSWORD=${DB_PASSWORD} psql -U postgres -h $STAGING_DB_HOST -c"ALTER DATABASE ${TARGET_DB} RENAME TO ${TARGET_DB}_old"
    PGPASSWORD=${DB_PASSWORD} psql -U postgres -h $STAGING_DB_HOST -c"ALTER DATABASE ${NEW_DB} RENAME TO ${TARGET_DB}"
    PGPASSWORD=${DB_PASSWORD} psql -U postgres -h $STAGING_DB_HOST -c"DROP DATABASE ${NEW_DB}"
fi

