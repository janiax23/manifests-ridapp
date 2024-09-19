#!/bin/bash

# Assign roles to the worker nodes
kubectl label node k8worker1 node-role.kubernetes.io/worker= --overwrite
kubectl label node k8worker2 node-role.kubernetes.io/worker= --overwrite

# Create namespace for the web app, using --save-config to avoid warning
kubectl create namespace ns-ridpharm-webapp --save-config || echo "Namespace already exists, skipping creation."

# Apply Kubernetes manifests
kubectl apply -f db-pv.yaml -n ns-ridpharm-webapp
kubectl apply -f db-pvc.yaml -n ns-ridpharm-webapp
kubectl apply -f html-files-configmap.yaml -n ns-ridpharm-webapp
kubectl apply -f nginx-configmap.yaml -n ns-ridpharm-webapp
kubectl apply -f db-deployment.yaml -n ns-ridpharm-webapp
kubectl apply -f db-service.yaml -n ns-ridpharm-webapp
kubectl apply -f backend-deployment.yaml -n ns-ridpharm-webapp
kubectl apply -f backend-service.yaml -n ns-ridpharm-webapp
kubectl apply -f nginx-deployment.yaml -n ns-ridpharm-webapp
kubectl apply -f nginx-service.yaml -n ns-ridpharm-webapp
kubectl apply -f namespace_annotation.yaml --save-config

# Function to check if all pods are running
check_pods_running() {
  while true; do
    echo "Waiting for all pods to be in 'Running' state..."
    # Check if any pods are not in the 'Running' state
    if kubectl get pods --all-namespaces --no-headers | awk '{print $4}' | grep -v 'Running' > /dev/null 2>&1; then
      sleep 10
    else
      echo "All pods are running!"
      break
    fi
  done
}

# Wait for all pods to be running
check_pods_running
