
DOCKER=podman
#DOCKER=sudo docker

CONTAINER_NAME=tiddlyhost-db

start-db:
	$(DOCKER) run \
	  --detach \
	  --rm \
	  --name $(CONTAINER_NAME) \
	  --env POSTGRES_PASSWORD=notsecure123 \
	  --publish 5432:5432 \
	  --volume dbvol:/var/lib/postgresql/data \
	  postgres:13

stop-db:
	$(DOCKER) stop $(CONTAINER_NAME)

signup-link:
	@cat log/development.log | grep "Confirm my account" | tail -1 | cut -d\" -f2

forgot-link:
	@cat log/development.log | grep "Change my password" | tail -1 | cut -d\" -f2
