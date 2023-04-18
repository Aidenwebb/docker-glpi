DOCKER_TAG = docker-glpi
DOCKER_REVISION ?= testing-$(USER)

.PHONY: build-image
build-image:
	docker build -t ${DOCKER_TAG}:${DOCKER_REVISION} .

.PHONY: run-image-dev
run-image:
	docker run -it --rm -p 8080:80 ${DOCKER_TAG}:${DOCKER_REVISION}

.PHONY: start-mariadb
start-mariadb-dev:
	docker run --rm -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=glpi -e MYSQL_DATABASE=glpi -e MYSQL_USER=glpi -e MYSQL_PASSWORD=glpi mariadb:10.7

.PHONY: start-dev
start-dev: start-mariadb build-image run-image-dev