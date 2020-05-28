#!/bin/bash

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
# No Color
NC='\033[0m'

# The project directory.
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
>&2 echo -e "${GREEN}Current project dir - ${PROJECT_DIR}${NC}"

# .env-dev loading in the shell
DOT_ENV_FILE=${PROJECT_DIR}/.env-dev
dotenv() {
    if [ -f "${DOT_ENV_FILE}" ]
    then
        set -a
        [ -f ${DOT_ENV_FILE} ] && . ${DOT_ENV_FILE}
        set +a
    else
        >&2 echo -e "${YELLOW}No .env-dev file found${NC}"
    fi
}
# Run dotenv
dotenv

# If environment variables are set, use them. If not, use the defaults.
export RSTUDIO_PORT=${RSTUDIO_PORT:-8787}
export R_VERSION=${R_VERSION:-3.6.2}
