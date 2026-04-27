REGISTRY := ghcr.io/roxabi
ML_BASE_TAG := cu128-py312-torch2.7.1

.PHONY: build-base push-base build-ml-base push-ml-base

build-base:
	docker build -t $(REGISTRY)/base:latest images/base/

push-base: build-base
	docker push $(REGISTRY)/base:latest

build-ml-base:
	docker build \
		-t $(REGISTRY)/ml-base:latest \
		-t $(REGISTRY)/ml-base:$(ML_BASE_TAG) \
		images/ml-base/

push-ml-base: build-ml-base
	docker push $(REGISTRY)/ml-base:latest
	docker push $(REGISTRY)/ml-base:$(ML_BASE_TAG)
