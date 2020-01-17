#!/bin/bash

YELLOW="\033[1;33m"
GREEN="\033[0;32m"
# No Color
NC='\033[0m'

BASE_URL='postgres://postgres:T!tus0s30@sage-test.cau5la50px0r.us-west-2.rds.amazonaws.com'

TARGET_DB=iatlas_staging
NEW_DB=${TARGET_DB}_`date +"%s"`

# Make the new temporary DB
echo "${GREEN}Creating new target DB @ ${BASE_URL}/postgres${NC}"
psql "${BASE_URL}/postgres" -c"CREATE DATABASE ${NEW_DB}"
echo "${GREEN}Restoring to DB @ ${BASE_URL}/${TARGET_DB}${NC}"
pg_restore -d ${BASE_URL}/${NEW_DB} /tmp/iatlas_dev.pgdata
echo "${GREEN}Swapping new and target DB @ ${BASE_URL}/postgres${NC}"
psql "${BASE_URL}/postgres" -c"ALTER DATABASE ${TARGET_DB} RENAME TO ${TARGET_DB}_old"
psql "${BASE_URL}/postgres" -c"ALTER DATABASE ${NEW_DB} RENAME TO ${TARGET_DB}"
psql "${BASE_URL}/postgres" -c"DROP DATABASE ${NEW_DB}"




