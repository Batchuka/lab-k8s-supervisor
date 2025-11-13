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

# Configure AWS CLI with the necessary credentials
aws configure

# Install Cluster API and related components
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/latest/download/clusterctl-linux-amd64 -o /usr/local/bin/clusterctl
chmod +x /usr/local/bin/clusterctl

# Initialize Cluster API with AWS provider
clusterctl init --infrastructure aws

# Additional setup can be added here as needed
# For example, configuring kubeconfig or other cluster settings

echo "EC2 bootstrap host setup completed."