!/bin/bash
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
# No Color
NC='\033[0m'
# The local scripts directory (assumes this file is in the root of the project folder).
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && cd ../ && pwd )"
>&2 echo -e "${GREEN}Current project dir - ${PROJECT_DIR}${NC}"
# .env loading in the shell
# dotenv() {
#   set -a
#   [ -f ${PROJECT_DIR}/.env-dev ] && . ${PROJECT_DIR}/.env-dev
#   set +a
# }
# Run dotenv
# dotenv
docker-compose up -d
docker exec -it iatlas-rstudio bash