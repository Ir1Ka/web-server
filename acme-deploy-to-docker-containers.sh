#!/bin/bash

source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")"/.env

HOSTS=(${HOST} home nps nps.${HOST})

docker-compose exec acme.sh --register-account -m "${EMAIL}"

function issue() {
  local HOST=$1
  [ -n "${HOST}" ] || return 1

  echo "isue ${HOST}.${DOMAIN} and *.${HOST}.${DOMAIN}"
  docker-compose exec -e GD_Key="${GD_Key}"                   \
                      -e GD_Secret="${GD_Secret}"             \
                     acme.sh --issue -d "${HOST}.${DOMAIN}"   \
                                     -d "*.${HOST}.${DOMAIN}" \
                             --dns dns_gd
}

function deploy() {
  local HOST=$1
  [ -n "${HOST}" ] || return 1
  local HOST_=$(python3 -c "print('.'.join('${HOST}'.split('.')[::-1]))")
  local DOMAIN_=${HOST}.${DOMAIN}
  local KEY_DIR=/etc/nginx/ssl/${HOST_}

  echo "deploy ${DOMAIN_} for label ${DOMAIN}"
  docker-compose exec -e DEPLOY_DOCKER_CONTAINER_LABEL=sh.acme.autoload.domain=${DOMAIN}  \
                      -e DEPLOY_DOCKER_CONTAINER_KEY_FILE="${KEY_DIR}-key.pem"            \
                      -e DEPLOY_DOCKER_CONTAINER_CERT_FILE="${KEY_DIR}-cert.pem"          \
                      -e DEPLOY_DOCKER_CONTAINER_CA_FILE="${KEY_DIR}-ca.pem"              \
                      -e DEPLOY_DOCKER_CONTAINER_FULLCHAIN_FILE="${KEY_DIR}-full.pem"     \
                      -e DEPLOY_DOCKER_CONTAINER_RELOAD_CMD="service nginx force-reload"  \
                     acme.sh --deploy -d ${DOMAIN_}  --deploy-hook docker
}

for host in "${HOSTS[@]}"; do
  issue ${host}
  deploy ${host}
done
