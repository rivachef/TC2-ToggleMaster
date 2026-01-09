#!/bin/bash

# ===== VARIÁVEIS =====
CLUSTER_NAME=togglemaster-cluster
REGION=us-east-1
K8S_VERSION=1.34
NODEGROUP_NAME=togglemaster-ng
INSTANCE_TYPE=t3.medium
DESIRED=2
MIN=1
MAX=4

# Substitua pelas SUAS subnets públicas
SUBNETS="subnet-0cc4880a7c9de8309,subnet-08a35322a9964ad86"
SECURITY_GROUPS="sg-07bdad4d32923f41a"

CLUSTER_ROLE_ARN="arn:aws:iam::223517439672:role/LabRole"
NODE_ROLE_ARN="arn:aws:iam::223517439672:role/c184285a4776817l12485365t1w223517439-LabEksNodeRole-DPRBDT2pbi3z"

# ===== CRIAR CLUSTER =====
aws eks create-cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --kubernetes-version $K8S_VERSION \
  --role-arn $CLUSTER_ROLE_ARN \
  --resources-vpc-config subnetIds=$SUBNETS,securityGroupIds=$SECURITY_GROUPS

echo "⏳ Aguardando cluster ficar ACTIVE..."
aws eks wait cluster-active \
  --name $CLUSTER_NAME \
  --region $REGION

# ===== CRIAR NODE GROUP =====
aws eks create-nodegroup \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name $NODEGROUP_NAME \
  --region $REGION \
  --scaling-config minSize=$MIN,maxSize=$MAX,desiredSize=$DESIRED \
  --subnets subnet-0cc4880a7c9de8309 subnet-08a35322a9964ad86 \
  --instance-types $INSTANCE_TYPE \
  --ami-type AL2023_x86_64_STANDARD \
  --node-role $NODE_ROLE_ARN

echo "⏳ Aguardando node group ficar ACTIVE..."
aws eks wait nodegroup-active \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name $NODEGROUP_NAME \
  --region $REGION

echo "✅ Cluster e Node Group prontos!"
