REGISTRY := ghcr.io/roxabi
ML_BASE_TAG := cu128-py312-torch2.7.1

.PHONY: build-base push-base build-ml-base push-ml-base

build-base:
	docker buildx build -t $(REGISTRY)/base:latest images/base/

push-base:
	docker buildx build --push -t $(REGISTRY)/base:latest images/base/

build-ml-base:
	docker buildx build \
		-t $(REGISTRY)/ml-base:latest \
		-t $(REGISTRY)/ml-base:$(ML_BASE_TAG) \
		images/ml-base/

push-ml-base:
	docker buildx build --push \
		-t $(REGISTRY)/ml-base:latest \
		-t $(REGISTRY)/ml-base:$(ML_BASE_TAG) \
		images/ml-base/
