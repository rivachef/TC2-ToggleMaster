# Projeto ToogleMaster - FIAP Tech Challenge Fase 2 

## Repositórios
- [auth-service](https://github.com/rivachef/auth-service)
- [flag-service](https://github.com/rivachef/flag-service)
- [targeting-service](https://github.com/rivachef/targeting-service)
- [evaluation-service](https://github.com/rivachef/evaluation-service)
- [analytics-service](https://github.com/rivachef/analytics-service)

## Cria o cluster EKS na AWS
./eks-create-cluster.sh


## Atualiza o Contexto do EKS para acesso
aws eks update-kubeconfig \
  --region us-east-1 \
  --name togglemaster-cluster \
  --alias togglemaster

kubectl config use-context togglemaster

aws sts get-caller-identity

kubectl get nodes


## Metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl top nodes
kubectl top pods -A


## NGINX Ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
--namespace ingress-nginx \
--create-namespace

kubectl get svc -n ingress-nginx

## 
kubectl apply -f namespace/namespace.yaml
kubectl apply -f nginx-ingress/ingress.yaml
kubectl apply -f k8s/auth-service/db/ 
kubectl apply -f k8s/auth-service/
kubectl apply -f k8s/flag-service/db/
kubectl apply -f k8s/flag-service/
kubectl apply -f k8s/targeting-service/db/
kubectl apply -f k8s/targeting-service/
kubectl apply -f k8s/evaluation-service/
kubectl apply -f k8s/analytics-service/

## Cria admin key
curl -X POST http://a8a2be5699e334a4780352fd035d5958-1879883264.us-east-1.elb.amazonaws.com/auth/admin/keys \
-H "Content-Type: application/json" \
-H "Authorization: Bearer admin-secreto-123" \
-d '{"name": "meu-primeiro-servico"}'

## Cria admin para flag service
curl -X POST http://a8a2be5699e334a4780352fd035d5958-1879883264.us-east-1.elb.amazonaws.com/auth/admin/keys \
-H "Content-Type: application/json" \
-H "Authorization: Bearer admin-secreto-123" \
-d '{"name": "admin-para-flag-service"}'

curl -X POST http://a8a2be5699e334a4780352fd035d5958-1879883264.us-east-1.elb.amazonaws.com/flags/flags \
-H "Content-Type: application/json" \
-H "Authorization: Bearer tm_key_e2d30c90287404d22eb1bc62a6cf8c5dd35cffe7a29ed155070d6d8eb07ca7b6" \
-d '{
    "name": "enable-new-dashboard",
    "description": "Ativa o novo dashboard para usuários",
    "is_enabled": true
}'


## Cria chave de API de serviço
curl -X POST http://a8a2be5699e334a4780352fd035d5958-1879883264.us-east-1.elb.amazonaws.com/auth/admin/keys \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer admin-secreto-123" \
    -d '{"name": "evaluation-service-key"}'

## Teste de Evaluation
curl "http://a8a2be5699e334a4780352fd035d5958-1879883264.us-east-1.elb.amazonaws.com/evaluation/evaluate?user_id=user-123&flag_name=enable-new-dashboard"

meu-primeiro-servico    -   tm_key_0a465f1d429f5e0a142e6fa20a7ea978a40eeebb252a8aa3c7fb04a85c278bdf

SUA_CHAVE_API           -   tm_key_e2d30c90287404d22eb1bc62a6cf8c5dd35cffe7a29ed155070d6d8eb07ca7b6

SUA_CHAVE_DE_SERVICO    -   tm_key_07e90c1e649a14fe36a4b63facb586ab7066626dba708f8b394eaef262c20246

