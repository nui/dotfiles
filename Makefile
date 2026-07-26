.PHONY: alpine-image


HEAD_COMMIT_ID := $(shell git rev-parse HEAD)
CURRENT_BRANCH := $(shell git branch --show-current)

# https://stackoverflow.com/a/24264930
GH_BRANCH      ?= $(CURRENT_BRANCH)

alpine-image:
	gh workflow run build-dotfiles-alpine-image.yml --ref $(GH_BRANCH)

