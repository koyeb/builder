PACK_FLAGS?=
PACK_BUILD_FLAGS?=--trust-builder
PACK_CMD?=pack

clean: clean-linux

####################
## Linux
####################

patch:
	./patch.sh $(SAMPLES_ROOT)/builders/heroku/20/builder.toml
	./patch.sh $(SAMPLES_ROOT)/builders/paketo/18/builder.toml

images:
	@docker build --pull -f Dockerfile.build --build-arg STACK=heroku-20 --build-arg BASE_IMAGE=heroku/heroku:20-build -t koyeb/pack:20-cnb-build .
	@docker build --pull -f Dockerfile.run --build-arg STACK=heroku-20 --build-arg BASE_IMAGE=heroku/heroku:20 -t koyeb/pack:20-cnb .

build-heroku: build-heroku-20

build-heroku-20: build-root
	@echo "> Building 'heroku-20' builder..."
	$(PACK_CMD) builder create koyeb/builder:heroku-20 --config $(SAMPLES_ROOT)/builders/heroku/20/builder.toml $(PACK_FLAGS)

build-paketo: build-paketo-18

build-paketo-18: build-root
	@echo "> Building 'paketo-18' builder..."
	$(PACK_CMD) builder create koyeb/builder:paketo-18 --config $(SAMPLES_ROOT)/builders/paketo/18/builder.toml $(PACK_FLAGS)

clean-linux:
	@echo "> Removing builders..."
	docker rmi koyeb/builder:paketo-18 || true

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

.PHONY: buildpacks
SAMPLES_ROOT:=.
build-root: buildpacks
