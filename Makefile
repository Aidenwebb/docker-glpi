DOCKER_TAG = docker-glpi
DOCKER_REVISION ?= testing-$(USER)

DEV_NETWORK_NAME = glpi-dev
GLPI_CONTAINER_NAME = glpi-dev-glpi
GLPI_DATA_VOLUME_NAME = v-glpi-dev-glpi
MARIADB_CONTAINER_NAME = glpi-dev-mariadb
MARIADB_DATA_VOLUME_NAME = v-glpi-dev-mariadb



.PHONY: build-image
build-image:
	docker build -t ${DOCKER_TAG}:${DOCKER_REVISION} .

# Docker Network
.PHONY: create-docker-dev-network
create-docker-dev-network:
	docker network inspect ${DEV_NETWORK_NAME} >/dev/null 2>&1 || docker network create ${DEV_NETWORK_NAME}

.PHONY: remove-docker-dev-network
remove-docker-dev-network:
	docker network rm ${DEV_NETWORK_NAME} || true

# Docker Volumes

.PHONY: create-docker-dev-volume-glpi
create-docker-dev-volume-glpi:
	docker volume inspect ${GLPI_DATA_VOLUME_NAME} >/dev/null 2>&1 || docker volume create ${GLPI_DATA_VOLUME_NAME}

.PHONY: remove-docker-dev-volume-glpi
remove-docker-dev-volume-glpi:
	docker volume rm ${GLPI_DATA_VOLUME_NAME} || true

.PHONY: create-docker-dev-volume-mariadb
create-docker-dev-volume-mariadb:
	docker volume inspect ${MARIADB_DATA_VOLUME_NAME} >/dev/null 2>&1 || docker volume create ${MARIADB_DATA_VOLUME_NAME}

.PHONY: remove-docker-dev-volume-mariadb
remove-docker-dev-volume-mariadb:
	docker volume rm ${MARIADB_DATA_VOLUME_NAME} || true

# GLPI container (non persistent)
.PHONY: stop-glpi
stop-glpi:
	docker container stop ${GLPI_CONTAINER_NAME} || true

.PHONY: start-glpi
start-glpi:
	docker run -it --rm --network ${DEV_NETWORK_NAME} --name ${GLPI_CONTAINER_NAME} -p 8080:80 ${DOCKER_TAG}:${DOCKER_REVISION}

.PHONY: start-glpi-persist
start-glpi-persist:
	docker run -it --rm --network ${DEV_NETWORK_NAME} --name ${GLPI_CONTAINER_NAME} --mount src=${GLPI_DATA_VOLUME_NAME},target=/var/www/html/glpi -p 8080:80 ${DOCKER_TAG}:${DOCKER_REVISION} 

# MariaDB container
.PHONY: stop-mariadb
stop-mariadb: 
	docker container stop ${MARIADB_CONTAINER_NAME} || true

.PHONY: start-mariadb
start-mariadb:
	docker container inspect ${MARIADB_CONTAINER_NAME} >/dev/null 2>&1 || docker run --rm -d --network ${DEV_NETWORK_NAME} --name ${MARIADB_CONTAINER_NAME} -p 3306:3306 -e MYSQL_ROOT_PASSWORD=glpi -e MYSQL_DATABASE=glpi -e MYSQL_USER=glpi -e MYSQL_PASSWORD=glpi mariadb:10.7

.PHONY: start-mariadb-persist
start-mariadb-persist:
	docker container inspect ${MARIADB_CONTAINER_NAME} >/dev/null 2>&1 || docker run --rm -d --network ${DEV_NETWORK_NAME} --name ${MARIADB_CONTAINER_NAME} --mount src=${MARIADB_DATA_VOLUME_NAME},target=/var/lib/mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=glpi -e MYSQL_DATABASE=glpi -e MYSQL_USER=glpi -e MYSQL_PASSWORD=glpi mariadb:10.7

# Start/Stop Dev

.PHONY: stop-dev
stop-dev: stop-mariadb stop-glpi remove-docker-dev-network remove-docker-dev-volume-glpi remove-docker-dev-volume-mariadb

.PHONY: start-dev
start-dev: create-docker-dev-network start-mariadb build-image start-glpi

.PHONY: start-dev-persist
start-dev-persist: create-docker-dev-network create-docker-dev-volume-mariadb create-docker-dev-volume-glpi start-mariadb-persist build-image start-glpi-persist