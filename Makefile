PACK_FLAGS?=
PACK_BUILD_FLAGS?=--trust-builder
PACK_CMD?=pack

clean: clean-linux

####################
## Linux
####################

patch:
	./patch.sh $(SAMPLES_ROOT)/builders/heroku/18/builder.toml
	./patch.sh $(SAMPLES_ROOT)/builders/heroku/20/builder.toml
	./patch.sh $(SAMPLES_ROOT)/builders/paketo/18/builder.toml

build-heroku: build-heroku-18 build-heroku-20

build-heroku-18: build-root
	@echo "> Building 'heroku-18' builder..."
	$(PACK_CMD) builder create koyeb/builder:heroku-18 --config $(SAMPLES_ROOT)/builders/heroku/18/builder.toml $(PACK_FLAGS)

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

SAMPLES_ROOT:=.
build-root:
