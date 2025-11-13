#!/bin/bash

# Step 1: Set variables
CLUSTER_NAME="my-cluster"
REGION="us-west-2"
CONTROL_PLANE_MACHINE_TYPE="t3.medium"
WORKER_MACHINE_TYPE="t3.medium"
NODE_COUNT=3

# Step 2: Create the cluster
echo "Creating managed cluster..."
clusterctl create cluster $CLUSTER_NAME --provider aws --kubeconfig ~/.kube/config --config cluster/cluster.yaml

# Step 3: Wait for the cluster to be ready
echo "Waiting for the cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=10m

# Step 4: Verify the cluster
echo "Verifying the cluster..."
kubectl get nodes

# Step 5: Output cluster information
echo "Managed cluster '$CLUSTER_NAME' created successfully in region '$REGION'."