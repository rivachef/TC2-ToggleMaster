.PHONY: all up build-images deploy delete-cluster clean kind-load

CLUSTER_NAME ?= togglemaster
KUSTOMIZE_OVERLAY ?= homolog

all: up

## Cria cluster kind + builda imagens e aplica kustomize overlay
up:
	./scripts/cluster-up.sh $(CLUSTER_NAME) $(KUSTOMIZE_OVERLAY)

## Builda todas as imagens localmente (não carrega no kind)
build-images:
	docker build -t rivachef/auth-service:v1 ./auth-service
	docker build -t rivachef/flag-service:v1 ./flag-service
	docker build -t rivachef/targeting-service:v1 ./targeting-service
	docker build -t rivachef/evaluation-service:v1 ./evaluation-service
	docker build -t rivachef/analytics-service:v1 ./analytics-service

## Load build-images no cluster kind
kind-load: build-images
	@for img in rivachef/auth-service:v1 rivachef/flag-service:v1 rivachef/targeting-service:v1 rivachef/evaluation-service:v1 rivachef/analytics-service:v1 ; do \
	  kind load docker-image $$img --name $(CLUSTER_NAME) ; \
	done

## Aplica overlay kustomize (deploy)
deploy:
	kubectl apply -k k8s/overlays/$(KUSTOMIZE_OVERLAY)

## Limpa recursos e apaga cluster kind
clean:
	kubectl delete -k k8s/overlays/$(KUSTOMIZE_OVERLAY) || true
	kind delete cluster --name $(CLUSTER_NAME) || true

## Exemplo: make up KUSTOMIZE_OVERLAY=prod
