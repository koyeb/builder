PACK_CMD?=pack
BUILDER?=koyeb/builder:heroku-20
LIFECYCLE_VERSION?=0.15.3
LIFECYCLE?=buildpacksio/lifecycle:$(LIFECYCLE_VERSION)
CNB_PLATFORM_API?=0.8
SUBDIRS := $(wildcard */)

all: $(SUBDIRS)

$(SUBDIRS):
	$(PACK_CMD) build --builder $(BUILDER) --pull-policy if-not-present --lifecycle-image $(LIFECYCLE) -v --path $@ $(subst /,,$@)

.PHONY: all $(SUBDIRS)

