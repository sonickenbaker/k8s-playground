#!/bin/bash

HELM_VALUES="/k8s/examples/kong-k8s/helm-values-chart-2-12-0.yaml"
HELM_CHART_VERSION="2.12.0"

# Create cluster
kind delete cluster
kind create cluster --image=kindest/node:v1.21.12 --config /k8s/cluster-configs/1-node-ingress.yml

# Setup helm
helm repo add kong https://charts.konghq.com
helm repo update

# Install Istio
istioctl install --set profile=demo -y

# STAGE
NAMESPACE="stage"
kubectl create namespace "$NAMESPACE"
#helm install kong-proxy kong/kong --version "$HELM_CHART_VERSION" --set "ingressController.watchNamespaces={stage}" -f "$HELM_VALUES" -n "$NAMESPACE"
kubectl apply -n "$NAMESPACE" -f '/k8s/examples/kong-k8s/kong/*.yaml'
kubectl apply -n "$NAMESPACE" -f /k8s/examples/kong-k8s/echo/deployment.yaml
kubectl apply -n "$NAMESPACE" -f /k8s/examples/kong-k8s/echo/service.yaml

# kind only start
#kubectl patch service -n "$NAMESPACE" kong-proxy-kong-proxy -p '{"spec":{"type":"NodePort"}}'
#kubectl patch -n "$NAMESPACE" deployment kong-proxy-kong --patch-file /k8s/examples/kong-k8s/deployment-patch.yaml
# kind only end

kubectl apply -n "$NAMESPACE" -f /k8s/examples/kong-k8s/ingress.yaml
kubectl apply -f '/k8s/examples/kong-k8s/echo/*-stage.yml'

## Ingress controller and proxy in "prod" namespace
#NAMESPACE="prod"
#kubectl create namespace "$NAMESPACE"
#helm install kong-proxy kong/kong --version "$HELM_CHART_VERSION" --set "ingressController.watchNamespaces={prod}" -f "$HELM_VALUES" -n "$NAMESPACE"
#kubectl apply -n "$NAMESPACE" -f echo-deployment.yaml
#kubectl apply -n "$NAMESPACE" -f echo-service.yaml
#
## kind only start
#kubectl patch service -n "$NAMESPACE" kong-proxy-kong-proxy -p '{"spec":{"type":"NodePort"}}'
#kubectl patch -n "$NAMESPACE" deployment kong-proxy-kong --patch-file /k8s/examples/kong-k8s/deployment-patch.yaml
## kind only end
#
#kubectl apply -n "$NAMESPACE" -f /k8s/examples/kong-k8s/ingress-class.yaml
#kubectl apply -n "$NAMESPACE" -f /k8s/examples/kong-k8s/ingress.yaml
#kubectl apply -f '/k8s/examples/kong-k8s/echo-*-prod.yml'

# Export Istio related variables
sleep 10
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')
echo "Host: $INGRESS_HOST - Port: $INGRESS_PORT"