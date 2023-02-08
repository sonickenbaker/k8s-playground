#!/bin/bash

# Create the cluster
/usr/local/bin/kind create cluster --image=kindest/node:v1.21.12 --config /k8s/cluster-configs/1-node-nginx-ingress.yml

# Create the NGINX ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Create the Ingress resource
kubectl appy -f httpbin-ingress.yaml

# Create the deployment resource
kubectl appy -f httpbin-deployment.yaml

# Create the service resource
kubectl appy -f httpbin-deployment.yaml