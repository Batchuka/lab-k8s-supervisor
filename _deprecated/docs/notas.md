O `kind` (Kubernetes in Docker) é um utilitário que cria clusters, ele não depende de um cluster. Ele precisa de uma máquina host e, nesta mesma máquina, é preciso que hada o Docker. Depois de usar ele para criar um cluster dentro de um continair, não precisaremos mais dele.

Como ele teremos o k8s dentro de um container. Dentro desse k8s, precisamos instalar o `CAPI`. Ou seja, o CAPI é instalado como uma camada a mais em cima de um k8s, conferindo a ele a capacidade de gerenciar outros clusters Kubernetes de forma declarativa.

Pelo visto, a comunidade constuma chamar esse cluster que contém o CAPI de `bootstrap cluster`, porque é a partir dele que os clusters gerenciados nascem. Então suponha um *cluster B* que ainda não existe, o CAPI, no *cluster bootstrap*, lê o CR (Cluster) e executa ações para criar o cluster B do zero, conectando via Docker, cloud API, SSH, etc.

Tanto K8s quanto CAPI usam `YAMLs` para declarar recursos, mas com propósitos diferentes:

- K8s puro gerencia o que roda dentro de um cluster
- CAPI gerencia o próprio cluster como recurso.

`CRD` (Custom Resource Definition) é do Kubernetes puro. O CAPI usa CRDs intensivamente, mas não os inventou. Qualquer projeto que queira "ensinar o Kubernetes a entender um novo tipo de recurso" vai criar um CRD.

A partir de um CRD, você pode instanciar um `CR` (Custom Resource), um objeto lógico criado no cluster quando você entrega um YAML para ele — ele passa a existir no etcd, é versionado, observado pelos controllers. 

O `controller`, ao ver esse CR, executa ações no mundo real (como criar uma máquina, provisionar um cluster, etc.).


## Paralelo usando Python

**CRD = Classe (define o tipo) → kind: CustomResourceDefinition**

É como se você estivesse criando uma classe Python. Para isso você precisa do arquivo de declaração `cluster-crd.yaml`. Com isso daria o comando: 

```bash
kubectl apply -f cluster-crd.yaml
```

Isso equivale a declarar uma classe:

```python
class Cluster:
    def __init__(self, name, version, replicas):
        self.name = name
        self.version = version
        self.replicadas = replicas
```

**CR = objeto de definição (estado desejado)**



```python
# Isso representa o YAML aplicado — a intenção declarada
my_cluster = Cluster(name="prod", version="v1.30.0", replicas=3)

# "kubectl apply" envia um POST pra API do Kubernetes
if validate_against_CRD(my_cluster):
    etcd.store("Cluster", my_cluster.name, my_cluster)

```

Objeto armazenado seria algo como:

```json
// etcd armazena como chave-valor, com campos como .spec, .metadata, etc.
{
  "key": "/clusters/prod",
  "value": {
    "spec": {"version": "v1.30.0", "replicas": 3},
    "metadata": {...},
    "status": {...}
  }
}
```


**Controller → loop de reconciliação**
```python
def reconcile(cluster_obj):
    current_state = check_actual_cluster_state(cluster_obj.name)

    if current_state.replicas < cluster_obj.replicas:
        create_more_nodes(cluster_obj.replicas - current_state.replicas)
    elif current_state.replicas > cluster_obj.replicas:
        delete_extra_nodes(current_state.replicas - cluster_obj.replicas)
```


```python
# Controller roda em loop e reconcilia o estado desejado
for cluster_obj in etcd.get_all("Cluster"):
    reconcile(cluster_obj)
```






































# Bosta

**Kubernetes Puro (Deployment)**
```yaml
apiVersion: apps/v1 
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:latest

```

**Cluster API (Cluster)**
```yaml
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
  name: my-cluster
spec:
  clusterNetwork:
    pods:
      cidrBlocks: ["192.168.0.0/16"]
  controlPlaneRef:
    kind: KubeadmControlPlane
    name: my-cluster-control-plane
  infrastructureRef:
    kind: DockerCluster
    name: my-cluster
```