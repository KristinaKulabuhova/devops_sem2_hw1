#!/bin/sh
kind create cluster
istioctl install --set meshConfig.outboundTrafficPolicy.mode=REGISTRY_ONLY --set profile=demo -y
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=90s
kubectl apply -f https://kind.sigs.k8s.io/examples/loadbalancer/metallb-config.yaml
kubectl create namespace devops
kubectl label namespace devops istio-injection=enabled
kubectl apply -f egress.yml
kubectl apply -f ingress.yml
kubectl apply -f service-a.yml
kubectl apply -f service-b.yml
kubectl wait --namespace devops --for=condition=ready pod --selector=app=service-b --timeout=90s
kubectl wait --namespace devops --for=condition=ready pod --selector=app=service-a --timeout=90s
kubectl port-forward deploy/service-a 9090:9090 -n devops & echo "DONE!"
