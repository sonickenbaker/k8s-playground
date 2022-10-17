#!/bin/bash

kubectl create namespace kafka
kubectl create namespace stage-old
kubectl create namespace stage-new
helm install my-kafka strimzi/strimzi-kafka-operator --namespace kafka --version 0.27.1 -f strimzi.yaml
kubectl apply -n stage-old -f kafka-old.yaml
sleep 120
kubectl apply -n stage-old -f kafka-topic.yaml
kubectl apply -n stage-old -f kafka-topic-2.yaml
kubectl apply -n stage-old -f kafka-topic-compact.yaml
kubectl apply -n stage-new -f kafka-new.yaml
sleep 120
#kubectl apply -n stage-new -f mirror-maker.yaml