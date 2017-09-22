#!/bin/bash -e

cd /app

source "env-vars"

COL_NO="\033[0m" # no color
COL_ERR="\033[1;31m" # light red

if [[ "$1" == "--unsafe" ]]; then
  echo -e "${COL_ERR}WARNING! Starting services in UNSAFE mode!${COL_NO}"
  # Disable Auth
  export PCS_AUTH_REQUIRED="false"
  # Allow cross-origin requests from anywhere
  export PCS_CORS_WHITELIST="{ 'origins': ['*'], 'methods': ['*'], 'headers': ['*'] }"
fi

list=$(docker ps -aq)
if [ -n "$list" ]; then
    docker rm -f $list
fi
rm -f nohup.out

nohup docker-compose up &

ISUP=$(curl -ks https://localhost/ | grep -i "html" | wc -l)
while [[ "$ISUP" == "0" ]]; do
  echo "Waiting for web site to start..."
  sleep 3
  ISUP=$(curl -ks https://localhost/ | grep -i "html" | wc -l)
done