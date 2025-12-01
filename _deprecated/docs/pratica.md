# The Pratice

## Bootstrap Cluster

Create a light cluster with kind to host the Cluster API

## Install CAPI

Us `clusterctl init` do put providers on bootstrap

## Define Templates

Write the `cluster-template.yaml` describing the target cluster, infra, control-plane and workers

## Provision the Target Cluster

Apply the template to CAPI and create the new cluster.

## Validate the Target Cluster

Make connection with kubeclt, check nodes/pods and messuring the times.

## Execute workloads

Up some basic application and observe

## Collect metrics

Measure latency, provisioning time, record results.
