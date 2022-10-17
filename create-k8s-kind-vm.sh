#!/bin/bash

VM_NAME="k8s-kind"
OS_VERSION="20.04"

if [ "$1" == "delete" ]
  then
    echo "Deleting $VM_NAME"
    multipass stop "$VM_NAME"
    multipass delete "$VM_NAME"
    multipass purge
fi

# Create the VM using multipass
multipass launch -c 4 -m 4G -d 15G --name "$VM_NAME" "$OS_VERSION"

# Mount shared folders
multipass mount "$HOME/personal_codebase/toolbox" "$VM_NAME":/toolbox
multipass mount "$HOME/personal_codebase/k8s-playground" "$VM_NAME":/k8s

# Provision
multipass exec "$VM_NAME" "/toolbox/provisioners/install_docker.sh"
multipass exec "$VM_NAME" "/toolbox/provisioners/install_kind.sh"
multipass exec "$VM_NAME" "/toolbox/provisioners/install_k8s_tools.sh"

# Create a cluster
# images from https://hub.docker.com/r/kindest/node/
#multipass exec "$VM_NAME" -- /usr/local/bin/kind create cluster --image=kindest/node:v1.21.12 --config /k8s/cluster-configs/3-node-cluster.yml
multipass exec "$VM_NAME" -- /usr/local/bin/kind create cluster --image=kindest/node:v1.21.12 --config /k8s/cluster-configs/1-node-nginx-ingress.yml

# Deploy istio
multipass exec "$VM_NAME" -- /usr/local/bin/istioctl install --set profile=demo -y
multipass exec "$VM_NAME" -- /usr/local/bin/kubectl label namespace default istio-injection=enabled
