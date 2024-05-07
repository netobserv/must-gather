IMAGE_REGISTRY ?= quay.io
IMAGE_TAG ?= latest
IMAGE ?= $(IMAGE_REGISTRY)/$(MUST_GATHER_IMAGE():$(IMAGE_TAG)
TAG_COMMIT := $(shell git rev-list --abbrev-commit --tags --max-count=1)
TAG := $(shell git describe --abbrev=0 --tags ${TAG_COMMIT} 2>/dev/null || true)
BUILD_VERSION := $(TAG:v%=%)
MULTIARCH_TARGETS ?= amd64

# Image building tool (docker / podman)
# Image building tool (docker / podman) - docker is preferred in CI
OCI_BIN_PATH := $(shell which docker 2>/dev/null || which podman)
OCI_BIN ?= $(shell basename ${OCI_BIN_PATH})

# build a single arch target provided as argument
define build_target
	echo 'building image for arch $(1)'; \
	DOCKER_BUILDKIT=1 $(OCI_BIN) buildx build --load --platform "$(1)" -t  ${IMAG}-$(1) -f Dockerfile .;
endef

# push a single arch target image
define push_target
	echo 'pushing image ${IMAGE}-$(1)'; \
	DOCKER_BUILDKIT=1 $(OCI_BIN) push ${IMAGE}-$(1);
endef

# MUST_GATHER_IMAGE needs to be passed explicitly to avoid accidentally pushing to netobserv/must-gather
check-image-env: ## Check MUST_GATHER_IMAGE make sure its set.
ifndef MUST_GATHER_IMAGE
	$(error MUST_GATHER_IMAGE is not set.)
endif

.PHONY: build
build: check-image-env image-build image-push manifest-build manifest-push ## check MUST_GATHER_IMAGE, build and push NetObserv collection image.

.PHONY: lint
lint: ## Run shellcheck against bash collection scripts.
ifeq (, $(shell which shellcheck))
	@echo "### shellcheck could not be found, skipping shell lint"
else
	@echo "### Run shellcheck against collection bash scripts"
	shellcheck -e SC2016 collection-scripts/*
endif

.PHONY: image-build
image-build: check-image-env ## Build NetObserv collection image.
	trap 'exit' INT; \
	$(foreach target,$(MULTIARCH_TARGETS),$(call build_target,$(target)))

.PHONY: image-push
image-push: check-image-env ## Push NetObserv collection image.
	trap 'exit' INT; \
	$(foreach target,$(MULTIARCH_TARGETS),$(call push_target,$(target)))

.PHONY: manifest-build
manifest-build: ## Build MULTIARCH_TARGETS manifest
	echo 'building manifest $(IMAGE)'
	DOCKER_BUILDKIT=1 $(OCI_BIN) rmi ${IMAGE} -f
	DOCKER_BUILDKIT=1 $(OCI_BIN) manifest create ${IMAGE} $(foreach target,$(MULTIARCH_TARGETS), --amend ${IMAGE}-$(target));

.PHONY: manifest-push
manifest-push: ## Push MULTIARCH_TARGETS manifest
	@echo 'publish manifest $(IMAGE)'
ifeq (${OCI_BIN}, docker)
	DOCKER_BUILDKIT=1 $(OCI_BIN) manifest push ${IMAGE};
else
	DOCKER_BUILDKIT=1 $(OCI_BIN) manifest push ${IMAGE} docker://${IMAGE};
endif

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
