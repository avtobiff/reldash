SECRET_KEY_BASE_FILE := config/SECRET_KEY_BASE

DOCKER_OPTS ?= 
DOCKER_CONTAINER_NAME ?= reldash
HOST ?= 


.PHONY: build
build:
	mix deps.get
	mix deps.compile
	mix compile

$(SECRET_KEY_BASE_FILE):
	mix phx.gen.secret > $(SECRET_KEY_BASE_FILE)

.PHONY: run
run: $(SECRET_KEY_BASE_FILE)
	MIX_ENV=prod \
		mix assets.deploy
	# export key then run server
	@export SECRET_KEY_BASE=$(shell cat $(SECRET_KEY_BASE_FILE)) ; \
	MIX_ENV=prod \
	PHX_HOST=$(HOST) \
		mix phx.server

.PHONY: run-dev
run-dev:
	mix phx.server

.PHONY: build-container
build-container: Dockerfile
	docker build $(DOCKER_OPTS) -t $(DOCKER_CONTAINER_NAME) .

.PHONY: start-container
start-container:
	docker run -d -p 4000:4000 $(DOCKER_OPTS) \
		--workdir /var/www/reldash/reldash \
		--name $(DOCKER_CONTAINER_NAME) \
		$(DOCKER_CONTAINER_NAME) \
		make run

.PHONY: start-container-fg
start-container-fg:
	docker run -p 4000:4000 $(DOCKER_OPTS) \
		--workdir /var/www/reldash/reldash \
		--name $(DOCKER_CONTAINER_NAME) \
		$(DOCKER_CONTAINER_NAME) \
		make run
