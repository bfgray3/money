.DEFAULT_GOAL := help

IMAGE ?= money-db
CONTAINER ?= money-db
MYSQL_DATABASE ?= money
MYSQL_PORT ?= 3306
MYSQL_VOLUME ?= money-db-data

.PHONY: help build run test

help:
	@echo "make build                         Build the MySQL image"
	@echo "MYSQL_ROOT_PASSWORD=... make run  Start the database container"
	@echo "make test                          Run database integration tests"

build:
	docker build --tag "$(IMAGE)" .

run:
	@test -n "$$MYSQL_ROOT_PASSWORD" || \
	  (echo "Set MYSQL_ROOT_PASSWORD before running this target." >&2; exit 1)
	docker run --name "$(CONTAINER)" \
	  -p "$(MYSQL_PORT):3306" \
	  -e MYSQL_ROOT_PASSWORD \
	  -e MYSQL_DATABASE="$(MYSQL_DATABASE)" \
	  -v "$(MYSQL_VOLUME):/var/lib/mysql" \
	  -d "$(IMAGE)"

test:
	@docker compose -f compose.test.yaml down --volumes --remove-orphans
	@docker compose -f compose.test.yaml up --build --abort-on-container-exit --exit-code-from tests; \
	  result=$$?; \
	  docker compose -f compose.test.yaml down --volumes --remove-orphans; \
	  exit $$result
