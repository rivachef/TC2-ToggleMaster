# Projeto ToogleMaster - FIAP Tech Challenge Fase 2 

## Repositórios
- [auth-service](https://github.com/rivachef/auth-service)
- [flag-service](https://github.com/rivachef/flag-service)
- [targeting-service](https://github.com/rivachef/targeting-service)
- [evaluation-service](https://github.com/rivachef/evaluation-service)
- [analytics-service](https://github.com/rivachef/analytics-service)

## Metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml 

## NGINX Ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
--namespace ingress-nginx \
--create-namespace

kubectl get svc -n ingress-nginx

## 
kubectl apply -f .\namespace\namespace.yaml
kubectl apply -f .\nginx-ingress\ingress.yaml
kubectl apply -f .\k8s\auth-service\db\ 
kubectl apply -f .\k8s\auth-service\
kubectl apply -f .\k8s\flag-service\db\
kubectl apply -f .\k8s\flag-service\
kubectl apply -f .\k8s\targeting-service\db\
kubectl apply -f .\k8s\targeting-service\
kubectl apply -f .\k8s\evaluation-service\
kubectl apply -f .\k8s\analytics-service\

curl -X POST http://aecd13ac705414984aea684882fdb74a-2114294751.us-east-1.elb.amazonaws.com/auth/admin/keys \
-H "Content-Type: application/json" \
-H "Authorization: Bearer admin-secreto-123" \
-d '{"name": "meu-primeiro-servico"}'

meu-primeiro-servico    -   tm_key_75dc25f31cc84968fac91a77e0f61cd28d07a7aec7e451264b3411b70cbe0e8f

SUA_CHAVE_API           -   tm_key_05ff8bf46f4e8f8ce2cc7d7cbbd749c13120ee1ac03e233d1ec536751460b458

curl -X POST http://aecd13ac705414984aea684882fdb74a-2114294751.us-east-1.elb.amazonaws.com/flags/flags \
-H "Content-Type: application/json" \
-H "Authorization: Bearer tm_key_05ff8bf46f4e8f8ce2cc7d7cbbd749c13120ee1ac03e233d1ec536751460b458" \
-d '{
    "name": "enable-new-dashboard",
    "description": "Ativa o novo dashboard para usuários",
    "is_enabled": true
}'