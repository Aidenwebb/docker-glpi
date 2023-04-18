DOCKER_TAG = docker-glpi
DOCKER_REVISION ?= testing-$(USER)

.PHONY: build-image
build-image:
	docker build -t ${DOCKER_TAG}:${DOCKER_REVISION} .

.PHONY: docker-dev-network
docker-dev-network:
	docker network inspect glpi-dev >/dev/null 2>&1 || docker network create glpi-dev

.PHONY: run-image-dev
run-image-dev:
	docker run -it --rm --network glpi-dev --name glpi-dev-glpi -p 8080:80 ${DOCKER_TAG}:${DOCKER_REVISION}

.PHONY: stop-mariadb
stop-mariadb: 
	docker container stop glpi-dev-mariadb

.PHONY: start-mariadb
start-mariadb:
	docker container inspect glpi-dev-mariadb >/dev/null 2>&1 || docker run --rm -d --network glpi-dev --name glpi-dev-mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=glpi -e MYSQL_DATABASE=glpi -e MYSQL_USER=glpi -e MYSQL_PASSWORD=glpi mariadb:10.7

.PHONY: start-dev
start-dev: docker-dev-network start-mariadb build-image run-image-dev