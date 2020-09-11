#!/bin/bash
clear

set -eu
set -o pipefail

function compileAndPackageTheApplication() {
    mvn clean package
}

# set up the environment
function setUpEnvironment() {
    local DOCKER_CONTAINER_NETWORK=$1

    local DOCKER_CONTAINER_NAME_DB=$2
    local DOCKER_CONTAINER_HOST_DB="${DOCKER_CONTAINER_NAME_DB}_postgres"

    local DB=$3
    local DB_USER=$4
    local DB_PASSWORD=$5
    local DB_PORT=5432

    local DOCKER_CONTAINER_NAME_APPLICATION=$6
    local DOCKER_CONTAINER_HOST_APPLICATION="${DOCKER_CONTAINER_NAME_APPLICATION}_micronaut"

    local MICRONAUT_APPLICATION_JAR=$7
    local MICRONAUT_APPLICATION_JDBC_URL="jdbc:postgresql://${DOCKER_CONTAINER_NAME_DB}:${DB_PORT}/${DB}"
    local MICRONAUT_APPLICATION_NAME=$8
    local MICRONAUT_APPLICATION_PORT=8080

    local LOCALHOST_DB_PORT=$9
    local LOCALHOST_MICRONAUT_APPLICATION_PORT=${10}

    local DOCKER_CONTAINER_NAME_SERVICE_DISCOVERY=${11}
    local DOCKER_CONTAINER_HOST_SERVICE_DISCOVERY="${DOCKER_CONTAINER_NAME_SERVICE_DISCOVERY}_consul"
    local LOCALHOST_SERVICE_DISCOVERY_PORT=${12}

    local SERVICE_DISCOVERY_PORT=8500

    docker network create --subnet 172.23.0.0/16 "${DOCKER_CONTAINER_NETWORK}"

    docker run -itd --rm \
        -p "${LOCALHOST_SERVICE_DISCOVERY_PORT}":"${SERVICE_DISCOVERY_PORT}" \
        --ip 172.23.0.2 \
        -h "${DOCKER_CONTAINER_HOST_SERVICE_DISCOVERY}" \
        --network="${DOCKER_CONTAINER_NETWORK}" \
        --name "${DOCKER_CONTAINER_NAME_SERVICE_DISCOVERY}" \
        consul:1.8.3

    docker run -it -d --rm \
        --ulimit memlock=-1:-1 \
        --memory-swappiness=0 \
        -e POSTGRES_USER="${DB_USER}" \
        -e POSTGRES_PASSWORD="${DB_PASSWORD}" \
        -e POSTGRES_DB="${DB}" \
        -p "${LOCALHOST_DB_PORT}":"${DB_PORT}" \
        -h "${DOCKER_CONTAINER_HOST_DB}" \
        --network="${DOCKER_CONTAINER_NETWORK}" \
        --name "${DOCKER_CONTAINER_NAME_DB}" \
        postgres:12.4

    docker run -it -d --rm \
        -e JDBC_URL="${MICRONAUT_APPLICATION_JDBC_URL}" \
        -e JDBC_USER="${DB_USER}" \
        -e JDBC_PASSWORD="${DB_PASSWORD}" \
        -e APPLICATION_NAME="${MICRONAUT_APPLICATION_NAME}" \
        -e APPLICATION_PORT="${MICRONAUT_APPLICATION_PORT}" \
        -e CONSUL_HOST="${DOCKER_CONTAINER_NAME_SERVICE_DISCOVERY}" \
        -e CONSUL_PORT="${SERVICE_DISCOVERY_PORT}" \
        -v "$(pwd)"/target/"${MICRONAUT_APPLICATION_JAR}":/opt/application/"${MICRONAUT_APPLICATION_JAR}" \
        -w /opt/application \
        -p 5005:5005 \
        -p "${LOCALHOST_MICRONAUT_APPLICATION_PORT}":"${MICRONAUT_APPLICATION_PORT}" \
        -h "${DOCKER_CONTAINER_HOST_APPLICATION}" \
        --network="${DOCKER_CONTAINER_NETWORK}" \
        --name "${DOCKER_CONTAINER_NAME_APPLICATION}" \
        adoptopenjdk/openjdk8:alpine-jre \
        java -Dcom.sun.management.jmxremote -Xmx128m -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 -jar /opt/application/"${MICRONAUT_APPLICATION_JAR}"
}

# terminate the environment
function dismantleEnvironment() {
    local DOCKER_CONTAINER_NETWORK=$1
    local -a DOCKER_CONTAINERS_TO_STOP=("${@:2}")

    docker stop "${DOCKER_CONTAINERS_TO_STOP[@]}"

    docker network rm "${DOCKER_CONTAINER_NETWORK}"
}

function askToExitGracefully() {
    echo -e "\r\n\r\n\r\n"
    local RESPONSE=
    while [[ ! ${RESPONSE} =~ ^[eE]|[xX][iI][tT] ]]; do
        read -r -p "    → Type « Exit » to dismantle the environment : " RESPONSE
    done
    echo -e "\r\n\r\n\r\n"
}

function run() {
    local MICRONAUT_APPLICATION_JAR=$1

    local MICRONAUT_APPLICATION_NAME=$2

    local DB=$3
    local DB_USER=$4
    local DB_PASSWORD=$5

    local LOCALHOST_DB_PORT=$6
    local LOCALHOST_MICRONAUT_APPLICATION_PORT=$7

    local DOCKER_CONTAINER_NETWORK=$(tr '-' '_' <<<"${MICRONAUT_APPLICATION_NAME}")"_network"

    local DOCKER_CONTAINER_NAME_DB=$(tr '-' '_' <<<"${MICRONAUT_APPLICATION_NAME}")"_db"
    local DOCKER_CONTAINER_NAME_APPLICATION=$(tr '-' '_' <<<"${MICRONAUT_APPLICATION_NAME}")"_application"

    local LOCALHOST_SERVICE_DISCOVERY_PORT=$8
    local whatToReplace="-"
    local substitute="_"
    local DOCKER_CONTAINER_NAME_SERVICE_DISCOVERY=${MICRONAUT_APPLICATION_NAME//${whatToReplace}/${substitute}}"_service_discovery"

    compileAndPackageTheApplication

    setUpEnvironment "${DOCKER_CONTAINER_NETWORK}" \
        "${DOCKER_CONTAINER_NAME_DB}" "${DB}" "${DB_USER}" "${DB_PASSWORD}" \
        "${DOCKER_CONTAINER_NAME_APPLICATION}" "${MICRONAUT_APPLICATION_JAR}" "${MICRONAUT_APPLICATION_NAME}" \
        "${LOCALHOST_DB_PORT}" "${LOCALHOST_MICRONAUT_APPLICATION_PORT}" \
        "${DOCKER_CONTAINER_NAME_SERVICE_DISCOVERY}" "${LOCALHOST_SERVICE_DISCOVERY_PORT}"

    askToExitGracefully

    dismantleEnvironment "${DOCKER_CONTAINER_NETWORK}" "${DOCKER_CONTAINER_NAME_DB}" "${DOCKER_CONTAINER_NAME_APPLICATION}" "${DOCKER_CONTAINER_NAME_SERVICE_DISCOVERY}"
}

function main() {
    local APPLICATION_JAR="user-management-application.jar"

    local APPLICATION_NAME="user-manager"

    local DB="db_user_manager"
    local DB_USER="dbLoser"
    local DB_PASSWORD="theSecret"

    local LOCALHOST_DB_PORT=5432
    local LOCALHOST_APPLICATION_PORT=8080
    local LOCALHOST_SERVICE_DISCOVERY_PORT=8500

    run "${APPLICATION_JAR}" \
        "${APPLICATION_NAME}" \
        "${DB}" "${DB_USER}" "${DB_PASSWORD}" \
        "${LOCALHOST_DB_PORT}" "${LOCALHOST_APPLICATION_PORT}" \
        "${LOCALHOST_SERVICE_DISCOVERY_PORT}"
}

main
