#!/usr/bin/env bash
set -euo pipefail

# Script de conveniência para criar cluster kind, buildar imagens locais e aplicar manifests kustomize (homolog por padrão).
# Uso: ./scripts/cluster-up.sh [cluster-name] [kustomize-overlay]
# Ex: ./scripts/cluster-up.sh togglemaster homolog

CLUSTER_NAME="${1:-togglemaster}"
OVERLAY="${2:-homolog}"   # homolog ou prod

echo "cluster: $CLUSTER_NAME"
echo "kustomize overlay: $OVERLAY"

# 1) create kind cluster (se já existir, pergunta)
if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "Criando cluster kind '${CLUSTER_NAME}'..."
  kind create cluster --name "${CLUSTER_NAME}" --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF
else
  echo "Cluster '${CLUSTER_NAME}' already exists. Skipping creation."
fi

# 2) set kubecontext
KUBECONTEXT="kind-${CLUSTER_NAME}"
kubectl cluster-info --context "${KUBECONTEXT}" >/dev/null 2>&1 || echo "Using kubecontext ${KUBECONTEXT}"

# 3) Build Docker images locally and load into kind
# Lista de imagens (ajuste nomes/tags se necessário)
IMAGES=(
  "rivachef/auth-service:v1"
  "rivachef/flag-service:v1"
  "rivachef/targeting-service:v1"
  "rivachef/evaluation-service:v1"
  "rivachef/analytics-service:v1"
)

# Build images (usa o Dockerfile em cada pasta)
for img in "${IMAGES[@]}"; do
  # extrai repo nome para localizar path (assumindo padrão rivachef/<name>)
  repo="$(echo "${img}" | cut -d'/' -f2 | cut -d: -f1)"
  tag="$(echo "${img}" | cut -d: -f2)"
  echo "Building image ${img} from folder ./${repo}..."
  docker build -t "${img}" "./${repo}"
  echo "Loading ${img} into kind..."
  kind load docker-image "${img}" --name "${CLUSTER_NAME}"
done

# 4) Apply namespace
echo "Applying namespace..."
kubectl apply -f k8s/namespaces/namespace.yaml --context="${KUBECONTEXT}"

# 5) Apply base infra (PVCs, secrets, configmaps, postgres stateful / deployments)
echo "Applying kustomize base..."
kubectl apply -k "k8s/overlays/${OVERLAY}" --context="${KUBECONTEXT}"

echo "Done. Use 'kubectl get pods -n togglemaster --context=${KUBECONTEXT}' to monitor."