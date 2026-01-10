#!/bin/bash

# ===== VARIÁVEIS =====
CLUSTER_NAME=togglemaster-cluster
REGION=us-east-1
NODEGROUP_NAME=togglemaster-ng

echo "🧨 Iniciando remoção do Node Group..."

aws eks delete-nodegroup \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name $NODEGROUP_NAME \
  --region $REGION

echo "⏳ Aguardando Node Group ser removido..."
aws eks wait nodegroup-deleted \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name $NODEGROUP_NAME \
  --region $REGION

echo "✅ Node Group removido com sucesso"

echo "🧨 Iniciando remoção do Cluster EKS..."

aws eks delete-cluster \
  --name $CLUSTER_NAME \
  --region $REGION

echo "⏳ Aguardando Cluster ser removido..."
aws eks wait cluster-deleted \
  --name $CLUSTER_NAME \
  --region $REGION

echo "✅ Cluster EKS removido com sucesso!"

