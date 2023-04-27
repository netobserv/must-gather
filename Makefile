IMAGE_REGISTRY ?= quay.io
IMAGE_TAG ?= latest

BUILD_VERSION := $(shell git describe --long HEAD)

# Image building tool (docker / podman)
ifndef OCI_BIN
ifeq (,$(shell which podman 2>/dev/null))
OCI_BIN=docker
else
OCI_BIN=podman
endif
endif

# MUST_GATHER_IMAGE needs to be passed explicitly to avoid accidentally pushing to netobserv/must-gather
check-image-env: ## Check MUST_GATHER_IMAGE make sure its set.
ifndef MUST_GATHER_IMAGE
	$(error MUST_GATHER_IMAGE is not set.)
endif

.PHONY: build
build: check-image-env image-build image-push ## check MUST_GATHER_IMAGE, build and push NetObserv collection image.

# check
check: ## Run shellcheck against bash collection scripts.
	shellcheck -e SC2016 collection-scripts/*

.PHONY: image-build
image-build: check-image-env ## Build NetObserv collection image.
	$(OCI_BIN) build --build-arg BUILD_VERSION="${BUILD_VERSION}" -t ${IMAGE_REGISTRY}/${MUST_GATHER_IMAGE}:${IMAGE_TAG} .

.PHONY: image-push
image-push: check-image-env ## Push NetObserv collection image.
	$(OCI_BIN) push ${IMAGE_REGISTRY}/${MUST_GATHER_IMAGE}:${IMAGE_TAG}


.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
