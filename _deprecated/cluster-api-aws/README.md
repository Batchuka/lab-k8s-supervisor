# Cluster API AWS Setup

This README provides step-by-step instructions for setting up the EC2 bootstrap host and creating a managed cluster using Cluster API on AWS.

## Prerequisites

- AWS account with appropriate permissions
- AWS CLI installed and configured
- kubectl installed
- Cluster API CLI installed
- Kustomize installed

## Step 1: Bootstrap EC2 Instance

1. **Run the EC2 Bootstrap Script**

   Execute the following command to set up the EC2 bootstrap host:

   ```
   bash scripts/setup-ec2-bootstrap.sh
   ```

   This script will:
   - Launch an EC2 instance
   - Install necessary dependencies
   - Configure the instance for Cluster API

## Step 2: Configure Cluster API

1. **Edit Cluster Configuration**

   Modify the `cluster/cluster.yaml` file to specify your desired cluster settings, including the number of nodes and networking configurations.

2. **Edit Control Plane Configuration**

   Update the `cluster/controlplane.yaml` file to define the control plane components and their settings.

3. **Edit Machine Deployment Configuration**

   Adjust the `cluster/machine-deployment.yaml` file to specify the worker node configurations.

## Step 3: Create Managed Cluster

1. **Run the Managed Cluster Creation Script**

   Execute the following command to create the managed cluster:

   ```
   bash scripts/create-managed-cluster.sh
   ```

   This script will:
   - Use the configurations defined in the previous steps
   - Provision the cluster on AWS

## Step 4: Verify Cluster Creation

1. **Check Cluster Status**

   Use the following command to verify that the cluster has been created successfully:

   ```
   kubectl get clusters
   ```

   Ensure that your cluster appears in the list and is in a healthy state.

## Additional Information

- For more details on the configuration files, refer to the respective YAML files in the `cluster` directory.
- The `configs/aws-cluster-api-config.yaml` file contains AWS-specific settings, including credentials and region information. Ensure this is configured correctly before running the scripts.
- The `tools/kustomization.yaml` file can be used for customizing Kubernetes resources as needed.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.