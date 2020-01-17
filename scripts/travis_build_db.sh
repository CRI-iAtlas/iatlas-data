#!/bin/bash

YELLOW="\033[1;33m"
GREEN="\033[0;32m"
# No Color
NC='\033[0m'

STAGING_DB_HOST=sage-test.cau5la50px0r.us-west-2.rds.amazonaws.com

TARGET_DB=iatlas_staging
NEW_DB=${TARGET_DB}_`date +"%s"`

# Make the new temporary DB
>&2 echo -e "${GREEN}Creating new target DB @ ${BASE_URL}/postgres${NC}"
PGPASSWORD='T!tus0s30' psql -U postgres -h $STAGING_DB_HOST  -c"CREATE DATABASE ${NEW_DB}"
>&2 echo -e "${GREEN}Restoring to DB @ ${BASE_URL}/${TARGET_DB}${NC}"
#pg_restore -d ${NEW_DB} -h /tmp/iatlas_dev.pgdata
>&2 -e echo "${GREEN}Swapping new and target DB @ ${BASE_URL}/postgres${NC}"
PGPASSWORD='T!tus0s30' psql -U postgres -h $STAGING_DB_HOST -c"ALTER DATABASE ${TARGET_DB} RENAME TO ${TARGET_DB}_old"
PGPASSWORD='T!tus0s30' psql -U postgres -h $STAGING_DB_HOST -c"ALTER DATABASE ${NEW_DB} RENAME TO ${TARGET_DB}"
PGPASSWORD='T!tus0s30' psql -U postgres -h $STAGING_DB_HOST -c"DROP DATABASE ${NEW_DB}"




