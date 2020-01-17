#!/bin/bash

YELLOW="\033[1;33m"
GREEN="\033[0;32m"
# No Color
NC='\033[0m'

TARGET_DB=iatlas_dev
NEW_DB=${TARGET_DB}_`date +"%s"`

BASE_URL='postgres://postgres:T!tus0s30@sage-test.cau5la50px0r.us-west-2.rds.amazonaws.com'
# Make the new temporary DB
psql "${BASE_URL}/postgres" -c"CREATE DATABASE ${NEW_DB}"
pg_restore -d ${BASE_URL}/${NEW_DB} /tmp/iatlas_dev.pgdata
psql "${BASE_URL}/postgres" -c"ALTER DATABASE ${TARGET_DB} RENAME TO ${TARGET_DB}_old"
psql "${BASE_URL}/postgres" -c"ALTER DATABASE ${NEW_DB} RENAME TO ${TARGET_DB}"
psql "${BASE_URL}/${NEW_DB}" -c"DROP DATABASE ${NEW_DB}"




