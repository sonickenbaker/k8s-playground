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
kubectl label namespace "$NAMESPACE" istio-injection=enabled --overwrite
#helm install kong-proxy kong/kong --version "$HELM_CHART_VERSION" --set "ingressController.watchNamespaces={stage}" -f "$HELM_VALUES" -n "$NAMESPACE"
kubectl apply -n "$NAMESPACE" -f '/k8s/examples/kong-k8s/kong/*.yaml'
kubectl apply -n "$NAMESPACE" -f '/k8s/examples/kong-k8s/kong/consumers/*.yaml'
kubectl apply -n "$NAMESPACE" -f '/k8s/examples/kong-k8s/kong/plugins/*.yaml'
kubectl apply -n "$NAMESPACE" -f /k8s/examples/kong-k8s/echo/deployment.yaml
kubectl apply -n "$NAMESPACE" -f /k8s/examples/kong-k8s/echo/service.yaml

cat << EOF > /home/ubuntu/jwtRS256.key.pub
-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAz4qDXyTQ8O22IIdqDof4
mH9EY8sipo2ySya7slZkOSwrCaiURn5RSru2bPeIOFNHpGvZW7EbiNNM63pRJYzd
mSs4ii9AD6wDy8CjQe7lXMkgEudAu1HZzEgqeCizyovVitN+TKm4A7QQckHPuclp
qt/UIPPy6lvL0VVlrFOQOxQXiFcJkcZZZrCUzfxYzXa1v2bcaPRGi8r06zGcxGCW
/F2r7UipIntV3ysAAiyrXQY37Y1piWMsoCFXH8pJBOA0lpikH4jXKoweI64iGAtf
quw8uHbifdOJDBh4y6nirH6xqM5wumb99cQ2p3tuMjkczQedMEefHXtJVEsZdpfU
s6CjquneOQqVhG9SnSRqOz4+NiWKMWcTPC+HmmJyKT+dTkxZ+bqDJ3cby+ZjzyjQ
a4QPMR6O9VTdfcVy10+8Xr2cdVXHLxQqaCIm7NqqGRYBfO2o9+C46/l8szQ2Hw+1
VZgWl2/JoSxbQI2BZkddbnIaX5y0RPz7u5LnkYQY0och36wqKDHiUjDqCDSxnUvt
uKbFKO+1naM4VJ7vzUnnnU3FmhDneAbhdfJvtYoLsdVrm7AFek+G4WlliLzz1NLI
MAJ7HEwR+61ZwhnoAmnZGGtpixKutzxors9ylJrKfhuly8s0thgbMQz/2A27us2p
pa+3ydT6uZTgz7NZWpgyymMCAwEAAQ==
-----END PUBLIC KEY-----
EOF

kubectl create -n "$NAMESPACE" secret \
  generic user-jwt \
  --from-literal=kongCredType=jwt \
  --from-literal=key="user-issuer" \
  --from-literal=algorithm=RS256 \
  --from-file=rsa_public_key="/home/ubuntu/jwtRS256.key.pub"

kubectl apply -n "$NAMESPACE" -f /k8s/examples/kong-k8s/ingress.yaml
kubectl apply -f '/k8s/examples/kong-k8s/echo/*-stage.yml'

## Ingress controller and proxy in "prod" namespace - TO BE FIXED
#NAMESPACE="prod"
#kubectl create namespace "$NAMESPACE"
#helm install kong-proxy kong/kong --version "$HELM_CHART_VERSION" --set "ingressController.watchNamespaces={prod}" -f "$HELM_VALUES" -n "$NAMESPACE"
#kubectl apply -n "$NAMESPACE" -f echo-deployment.yaml
#kubectl apply -n "$NAMESPACE" -f echo-service.yaml
#
#kubectl apply -n "$NAMESPACE" -f /k8s/examples/kong-k8s/ingress-class.yaml
#kubectl apply -n "$NAMESPACE" -f /k8s/examples/kong-k8s/ingress.yaml
#kubectl apply -f '/k8s/examples/kong-k8s/echo-*-prod.yml'

# Export Istio related variables
sleep 10
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')
echo "Host: $INGRESS_HOST - Port: $INGRESS_PORT"