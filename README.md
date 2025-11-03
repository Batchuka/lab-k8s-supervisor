# capi-lab-ec2

## Objetivo

Demonstrar a criação, orquestração e validação de clusters Kubernetes usando o Cluster API (CAPI) em um cenário com múltiplos ambientes (EC2 e Windows Desktop), avaliando tempo de provisionamento e funcionamento de workloads simples.

## Definição de Feito (Done Criteria)

O projeto será considerado concluído quando:
- Um bootstrap cluster com Kind estiver ativo em uma EC2
- O Cluster API estiver instalado e funcionando nesse bootstrap
- Um cluster Kubernetes gerenciado for criado via CAPI (com Docker) na EC2
- Um segundo cluster Kubernetes gerenciado for criado no Windows (com Docker) (borda)
- Workloads simples forem aplicados e testados
- Métricas forem coletadas e documentadas (tempo, latência, etc.)

## Papéis e Componentes

**Máquina EC2 (Ubuntu)**
- Função: Host do cluster de bootstrap

Componentes instalados:
- Docker → suporte ao Kind e aos clusters Docker
- Kind → cria o cluster de bootstrap
- Clusterctl → instala o Cluster API
- Kubectl → gerencia tudo
- Papel: central de controle, executa os manifestos e coordena a criação dos clusters

**Kind**
- Função: Cria um mini cluster Kubernetes dentro da EC2 usando Docker (requer apenas Docker no host; não depende de outro cluster)
- Papel: esse mini-cluster é o bootstrap cluster, onde o Cluster API será instalado
- Por quê? Porque o CAPI precisa de um cluster Kubernetes inicial pra funcionar

**Cluster API (CAPI)**
- Instalado dentro do Kind (bootstrap)
- Composto por diversos controllers:
- cluster-api-controller
- bootstrap-kubeadm-controller
- control-plane-kubeadm-controller
- infrastructure-* (Docker ou AWS)
- Papel: lê os YAMLs e cria clusters Kubernetes reais com base neles

**Cluster Gerenciado 1 (Docker na EC2)**
- Criado pelo CAPI, usando o provider infrastructure-docker
- Roda dentro da mesma EC2, mas como containers isolados
- Papel: cluster funcional com control-plane e workers
- Usado para validar o provisionamento em ambiente controlado

**Cluster Gerenciado 2 (Docker no Windows)**
- Criado remotamente pelo CAPI via SSH
- Ambiente “edge” (simula um nó de borda remoto)
- Papel: testar a criação de cluster em infraestrutura externa
- Requisitos: Windows com Docker, SSH ativo e kubeadm/kubelet/kubectl

**YAMLs**
- cluster.yaml: define o recurso Cluster (nome, rede, referências)
- controlplane.yaml: define como será o control-plane (replicas, infra, config)
- machine-deployment.yaml: define os workers e como nascem