# Conceitos Kubernetes + Cluster API

## Cluster
É o conjunto de máquinas (reais ou simuladas) que rodam o Kubernetes. O cluster possui um control-plane (que orquestra) e nodes (que executam os containers).

## Recurso (Resource)
É um tipo de objeto que o Kubernetes entende, como `Pod`, `Service`, `Deployment`. Todo recurso tem um endpoint REST associado na API do cluster.

## Objeto de Recurso
É uma instância concreta de um recurso. Um YAML aplicado via kubectl vira um objeto salvo no cluster.

## Custom Resource (CR)
É um novo tipo de recurso criado por alguém fora do Kubernetes padrão. Exemplo: `Cluster`, `Machine`, `AWSCluster`.

## Custom Resource Definition (CRD)
É o "molde" de um Custom Resource. Quando você instala um CRD, o Kubernetes passa a entender aquele novo tipo e expõe um novo endpoint na API.

## Controller
É um programa (geralmente rodando como Pod) que observa objetos de determinado tipo e executa ações para alinhar o estado real ao estado desejado.

## Custom Controller
É um controller feito sob medida para um Custom Resource. Ele define a lógica do que deve acontecer quando um CR muda.

## Declaração de Estado
Ao aplicar um YAML, estou declarando o estado que eu quero no cluster. Os controllers trabalham para que o estado real alcance esse estado desejado.

## Endpoint (na API)
É o caminho HTTP exposto pela API do Kubernetes para interagir com um tipo de recurso. Ex: `/api/v1/pods`, `/apis/cluster.x-k8s.io/v1beta1/clusters`.

## Cluster API
É um conjunto de CRDs + Controllers que permite criar e gerenciar clusters Kubernetes declarativamente, usando o Kubernetes como plataforma para orquestrar... ele mesmo.

## (novamente) Cluster API (CAPI)
É uma camada que estende o Kubernetes com novos recursos e controladores (via CRDs).
Com ele, você pode **declarar clusters Kubernetes como YAMLs**, e o CAPI cria, configura e gerencia esses clusters de forma automatizada.

## Kubernetes
É a plataforma que orquestra containers.
O Cluster API roda **dentro de um cluster Kubernetes existente**, usando-o como base para criar e gerenciar outros clusters.

## Kind
É uma ferramenta que cria um cluster Kubernetes dentro de containers Docker.
Serve principalmente para testes, desenvolvimento ou como **cluster bootstrap** onde o Cluster API será instalado.