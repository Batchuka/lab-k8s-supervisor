#cloud-config
# This file is used for EC2 instance user data to bootstrap the environment.

packages:
  - awscli
  - curl
  - jq
  - git

runcmd:
  - [ sh, -c, "curl -sSL https://get.k3s.io | sh -" ]
  - [ sh, -c, "systemctl enable k3s" ]
  - [ sh, -c, "systemctl start k3s" ]
  - [ sh, -c, "kubectl apply -f /path/to/your/cluster/cluster.yaml" ]
  - [ sh, -c, "kubectl apply -f /path/to/your/cluster/controlplane.yaml" ]
  - [ sh, -c, "kubectl apply -f /path/to/your/cluster/machine-deployment.yaml" ]

final_message: "The EC2 instance has been successfully bootstrapped and the cluster is being set up."