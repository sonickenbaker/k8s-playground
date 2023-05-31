# HttpBin Istio

## Description
Simple HttpBin service that is reachable via Istio's ingress gateway

## Deploy
`kubectl label namespace default istio-injection=enabled`
`kubectl apply -f '*.yml'`

## Test
```bash
# Set some variables (https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/)
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].nodePort}')
export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')

# Perform curl
```bash
curl -v "http://$INGRESS_HOST:$INGRESS_PORT/status/200"
```