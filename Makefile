.DEFAULT_GOAL := default

.PHONY: default build up down restart logs shell open clean

default:
	@echo "Usage:"
	@echo "  make build      Build the Docker image"
	@echo "  make up         Start the container"
	@echo "  make down       Stop and remove the container"
	@echo "  make restart    Rebuild and restart the container"
	@echo "  make logs       Tail container logs"
	@echo "  make shell      Open a shell inside the running container"
	@echo "  make open       Open the browser UI (https://localhost:6901)"
	@echo "  make clean      Stop container and remove image"

build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose up -d --build

logs:
	docker compose logs -f

shell:
	docker compose exec kasm-chrome /bin/bash

open:
	open https://localhost:6901

clean:
	docker compose down --rmi local --volumes --remove-orphans
