PACK_FLAGS?=
PACK_BUILD_FLAGS?=--trust-builder
PACK_CMD?=pack

clean: clean-linux

####################
## Linux
####################

build-linux: build-linux-builders

build-bionic: build-builder-bionic

build-linux-builders: build-builder-bionic

build-builder-bionic: build-root
	@echo "> Building 'bionic' builder..."
	$(PACK_CMD) builder create koyeb/builder:bionic --config $(SAMPLES_ROOT)/builders/bionic/builder.toml $(PACK_FLAGS)

deploy-linux: deploy-linux-builders

deploy-linux-builders:
	@echo "> Deploying 'bionic' builder..."
	docker push koyeb/builder:bionic

clean-linux:
	@echo "> Removing builders..."
	docker rmi koyeb/builder:bionic || true

	@echo "> Removing '.tmp'"
	rm -rf .tmp

set-experimental:
	@echo "> Setting experimental"
	$(PACK_CMD) config experimental true

SAMPLES_ROOT:=.
build-root:
