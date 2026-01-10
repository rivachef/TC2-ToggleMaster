#!/bin/bash

# ===== VARIÁVEIS =====

REDIS_NAME=togglemaster-redis  # Nome do Redis Cluster
REDIS_SG_IDS=sg-0d3985e5ee0330443  # Security Group do Redis
REDIS_SNET_GROUP_NAME=togglemaster-redis-subnet-group  # Subnet Group do Redis
SQS_NAME=togglemaster-queue  # Nome da SQS Queue
DYNAMODB_TABLE_NAME=ToggleMasterAnalytics  # Nome da tabela DynamoDB
AUTH_DB_ID=auth-db  # Host do banco de dados PostgreSQL do Auth Service
AUTH_DB_NAME=auth_db  # Nome do banco de dados PostgreSQL do Auth Service
FLAGS_DB_ID=flag-db  # Host do banco de dados PostgreSQL do Flag Service
FLAGS_DB_NAME=flag_db  # Nome do banco de dados PostgreSQL do Flag Service
TARGETING_DB_ID=targeting-db  # Host do banco de dados PostgreSQL do Targeting Service
TARGETING_DB_NAME=targeting_db  # Nome do banco de dados PostgreSQL do Targeting Service
POSTGRES_USER=tm_user  # Usuário do PostgreSQL
POSTGRES_PASSWORD=tm_pass_26  # Senha do PostgreSQL
POSTGRES_SNET_GROUP_NAME=rds-private-subnets  # Subnet Group do RDS
RDS_SG_ID=sg-0798b9c793bfe5eea  # Security Group do RDS

# ===== CRIAR INSTÂNCIAS RDS POSTGRESQL =====

# 1. Auth Service PostgreSQL
aws rds create-db-instance \
  --db-instance-identifier $AUTH_DB_ID \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 17.4 \
  --master-username $POSTGRES_USER \
  --master-user-password $POSTGRES_PASSWORD \
  --storage-type gp2 \
  --allocated-storage 20 \
  --db-name $AUTH_DB_NAME \
  --vpc-security-group-ids $RDS_SG_ID \
  --db-subnet-group-name $POSTGRES_SNET_GROUP_NAME \
  --no-publicly-accessible

# 2. Flag Service PostgreSQL
aws rds create-db-instance \
  --db-instance-identifier $FLAGS_DB_ID \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 17.4 \
  --master-username $POSTGRES_USER \
  --master-user-password $POSTGRES_PASSWORD \
  --storage-type gp2 \
  --allocated-storage 20 \
  --db-name $FLAGS_DB_NAME \
  --vpc-security-group-ids $RDS_SG_ID \
  --db-subnet-group-name $POSTGRES_SNET_GROUP_NAME \
  --no-publicly-accessible

# 3. Targeting Service PostgreSQL
aws rds create-db-instance \
  --db-instance-identifier $TARGETING_DB_ID \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 17.4 \
  --master-username $POSTGRES_USER \
  --master-user-password $POSTGRES_PASSWORD \
  --storage-type gp2 \
  --allocated-storage 20 \
  --db-name $TARGETING_DB_NAME \
  --vpc-security-group-ids $RDS_SG_ID \
  --db-subnet-group-name $POSTGRES_SNET_GROUP_NAME \
  --no-publicly-accessible

  
# Criar Redis Cluster no AWS ElastiCache
aws elasticache create-cache-cluster \
  --cache-cluster-id $REDIS_NAME \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-nodes 1 \
  --cache-subnet-group-name $REDIS_SNET_GROUP_NAME \
  --security-group-ids $REDIS_SG_IDS

# Criar SQS Queue no AWS
  aws sqs create-queue \
  --queue-name $SQS_NAME \
  --attributes VisibilityTimeout=30,MessageRetentionPeriod=86400

# Criar DynamoDB Table no AWS
aws dynamodb create-table \
  --table-name $DYNAMODB_TABLE_NAME \
  --attribute-definitions \
    AttributeName=event_id,AttributeType=S \
  --key-schema \
    AttributeName=event_id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
