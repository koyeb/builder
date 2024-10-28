PACK_FLAGS?=
PACK_BUILD_FLAGS?=--trust-builder
PACK_CMD?=pack
REGISTRY?=koyeb

####################
## Linux
####################

patch-builder-run-image:
	./patch-builder.sh $(SAMPLES_ROOT)/builders/heroku/22/builder.toml ${REGISTRY}
	./patch-builder.sh $(SAMPLES_ROOT)/builders/heroku/22-cnb/builder.toml ${REGISTRY}

patch:
	./patch.sh $(SAMPLES_ROOT)/builders/heroku/22-cnb/builder.toml

images:
	@docker build --pull -f Dockerfile.build --build-arg STACK=heroku-22 --build-arg BASE_IMAGE=heroku/heroku:22-build -t koyeb/pack:22-cnb-build .
	@docker build --pull -f Dockerfile.run --build-arg STACK=heroku-22 --build-arg BASE_IMAGE=heroku/heroku:22 -t koyeb/pack:22-cnb .

build-heroku: build-heroku-22

build-heroku-22: build-root
	@echo "> Building 'heroku-22' builder..."
	$(PACK_CMD) builder create ${REGISTRY}/builder:heroku-22 --config $(SAMPLES_ROOT)/builders/heroku/22/builder.toml $(PACK_FLAGS)

build-heroku-22-cnb: build-root
	@echo "> Building 'heroku-22-cnb' builder..."
	$(PACK_CMD) builder create ${REGISTRY}/builder:heroku-22-cnb --config $(SAMPLES_ROOT)/builders/heroku/22-cnb/builder.toml $(PACK_FLAGS)

clean:
	@echo "> Removing '.tmp'"
	rm -rf .tmp

set-experimental:
	@echo "> Setting experimental"
	$(PACK_CMD) config experimental true

build-command:
	$(PACK_CMD) buildpack package koyeb/build-command --config ./buildpacks/build-command/package.toml

custom: build-command
	$(PACK_CMD) buildpack package koyeb/buildpack-custom --config ./buildpacks/custom/package.toml

build-command-nodejs:
	$(PACK_CMD) buildpack package koyeb/build-command-nodejs --config ./buildpacks/build-command-nodejs/package.toml

custom-nodejs: build-command-nodejs
	$(PACK_CMD) buildpack package koyeb/buildpack-custom-nodejs --config ./buildpacks/custom-nodejs/package.toml

buildpacks: custom custom-nodejs

test:
	$(MAKE) -C ./test


.PHONY: buildpacks test
SAMPLES_ROOT:=.
build-root: buildpacks
