REGISTRY := ghcr.io/roxabi

.PHONY: build-base push-base build-ml-base push-ml-base

build-base:
	docker build -t $(REGISTRY)/base:latest images/base/

push-base: build-base
	docker push $(REGISTRY)/base:latest

build-ml-base:
	docker build -t $(REGISTRY)/ml-base:latest images/ml-base/

push-ml-base: build-ml-base
	docker push $(REGISTRY)/ml-base:latest
