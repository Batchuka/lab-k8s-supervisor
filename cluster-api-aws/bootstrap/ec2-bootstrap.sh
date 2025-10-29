#!/bin/bash

# Update the package manager and install necessary dependencies
sudo apt-get update
sudo apt-get install -y \
    curl \
    jq \
    git \
    awscli \
    kubectl \
    kubelet \
    kubeadm \
    kube-proxy

# Enable and start kubelet
sudo systemctl enable kubelet
sudo systemctl start kubelet

# Configure AWS CLI with IAM role or access keys
aws configure set region us-west-2
aws configure set output json

# Install Cluster API components
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/latest/download/clusterctl-linux-amd64 -o /usr/local/bin/clusterctl
chmod +x /usr/local/bin/clusterctl

# Initialize Cluster API
clusterctl init --infrastructure aws

# Additional configurations can be added here as needed
# For example, setting up a specific CNI plugin or other Kubernetes components

echo "EC2 bootstrap host setup complete."