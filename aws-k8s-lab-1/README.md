# Passo a passo para prática de provisionar k8s com CAPI na AWS

**OBJETIVO**: instanciar uma máquina EC2 na AWS e executar nela um cluster Kubernetes via kind, utilizado como management cluster para trabalhar com CRDs do Cluster API (CAPI).

**FERRAMENTAS** : Para isso usaremos `terraform` para provisionar e configurar recursos rapidamente, `ssh-keygen` para gerar chaves *ssh*, `AWS CLI` para dar comandos à AWS e `OpenSSH` como cliente *ssh* para se conectar ao EC2.

## 1 – Criação da chave SSH local

O `terraform` é um utilitário de linha de comando usado para configurar e provisionar recursos de forma declarativa. Entretanto, essa CLI não oferece suporte a download. Ou seja, é possível usá-lo para criar uma chave de acesso SSH para uma instância EC2, mas a ferramenta não a baixa automaticamente, o que torna o processo inútil nesse contexto.

Então, vamos gerar o par de chaves localmente e exportá-lo para uso no EC2. Usando o utilitário `ssh-keygen`, normalmente disponível em sistemas Unix, geraremos as chaves que serão usadas para acesso SSH à instância EC2. Por favor, navegue até a raiz do projeto e dê o seguinte comando — obs.: não utilize nenhuma `passphrase`:

```bash
ssh-keygen -t ed25519 -f .aws/ec2-keys/k8s-bootstrap-lab-key.pem
```
Isso cria dois arquivos:
- aws/ec2-keys/k8s-bootstrap-lab-key.pem        → chave privada (fica somente na máquina local)
- aws/ec2-keys/k8s-bootstrap-lab-key.pem.pub    → chave pública (enviada à AWS para compor o Key Pair)

## 2 – Provisionar a instância EC2 com Terraform

Agora navegue até a pasta *aws-k8s-lab-1/terraform*. Nessa pasta, preciso que faça a [Configuração das credenciais AWS](./README.md#configuração-das-credenciais-aws).

Inicializar o Terraform:
```bash
terraform init
```

Não coloque nenhuma frase nem nada, só dê enter 'vazio' em tudo.

Ver o plano:
```bash
terraform plan
```

Aplicar:
```bash
terraform apply
```

Depois, acessar via SSH:
```bash
ssh -i aws/ec2-keys/k8s-bootstrap-lab-key ubuntu@<IP_PUBLICO_EC2>
```

## 3 — Configurar a instância EC2 para virar o "Bootstrap Cluster"

`Bootstrap Cluster` é o nome dado ao cluster que tem a capacidade de criar outros clusters, isto é, ele serve para fazer o bootstrap de outros. Ele não serve para outras questões. Comumente, o que se faz é instalar uma versão reduzida do k8s só para instalar a camada do CAPI em cima. 

Entre ma máquina:

```bash
cd cd .aws/ec2-keys/
ssh -i "k8s-bootstrap-lab-key.pem" ubuntu@ec2-98-83-38-60.compute-1.amazonaws.com
```

> **NOTA.:** essa parte `ubuntu@ec2-98-83-38-60.compute-1.amazonaws.com` é dinâmica e atribuída pela AWS. É um hostname. 

<p align="center"><img src="../docs/images/image1.png" width="500"><br><em>onde encontrar o SSH de conexão no EC2</em></p>

Daí coisas triviais:

- Atualizar o sistema e instalar algumas coisas:
```
sudo apt update && sudo apt upgrade -y
```

- **Instalar Docker** (Kind precisa disso):
```bash
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
``` 

> NOTA.: Aqui é bom entrar e sair na instância, para reiniciar a sessão.

- **Instalar Kind**

O Kind é `Kubernetes In Docker`

```bash
curl -Lo kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x kind
sudo mv kind /usr/local/bin/
kind --version
```

- **Instalar kubectl**

`kubectl` é só o cliente que fala com o Kubernetes, é um CLI.

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```

- Criar o cluster Kind que será o management cluster
```bash
kind create cluster --name capi-mgmt
kubectl get nodes
```

## 4 — Inicialização do Cluster API no cluster de gerenciamento (Kind)

Nessa altura do campeonato você deve ter uma instancia EC2 com um docker instalado. Nesse docker um container está rodando, é uma imagem `kind`. Até o presente momento, temos um k8s normal só que rodando em um container. Então:

- `control-plane` rodando como container Docker.
- `etcd` rodando como container.
- Kubernetes completo, mas não é HA (um único control-plane por padrão).
- Nós virtuais rodando em containers (não são VMs).
- O storage é ephemeral (tudo morre se os containers morrem).
- Node interno com IP privado de rede Docker, não tem provisionamento real de nós físicos.

O que precisamos fazer agora é instlar o `clusterctl`. Ele é só um CLI que irá trocar uma ideia com o container para instalar no k8s os CRD's do CAPI.

Mas antes, você precisa mover os arquivos de credencial para dentro da máquina

```bash
ssh -i .aws/ec2-keys/k8s-bootstrap-lab-key.pem ubuntu@ec2-44-222-98-88.compute-1.amazonaws.com "mkdir -p ~/.aws"
scp -i .aws/ec2-keys/k8s-bootstrap-lab-key.pem .aws/credentials ubuntu@ec2-44-222-98-88.compute-1.amazonaws.com:~/.aws/credentials
```



```bash
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.7.2/clusterctl-linux-amd64 -o clusterctl
chmod +x clusterctl
sudo mv clusterctl /usr/local/bin/
export AWS_B64ENCODED_CREDENTIALS=$(base64 -w0 ~/.aws/credentials)
clusterctl init --infrastructure aws
kubectl get pods -A
kubectl get crds | grep cluster
```

Com isso, você instalou uma cama extra em cima do CAPI. Você instalou o CAPA, que dá ao CAPI o poder de criar recursos na AWS. Com isso você pode criar uma outra instância inteira e instalar Kubernetes nela, por exemplo. Pode também subir serviços no ECS e trata-los como pods.

Na prática, seu EC2 agora é oficialmente um “orquestrador de clusters Kubernetes”.

## 5 — Crie seu primeiro Workload

```bash
export AWS_REGION="us-east-1"
export AWS_SSH_KEY_NAME="k8s-bootstrap-lab-key"
export AWS_CONTROL_PLANE_MACHINE_TYPE="t3.medium"
export AWS_NODE_MACHINE_TYPE="t3.medium"
```

Para o apply dos manifests dentro do cluster de gerenciamento.

```bash
clusterctl generate cluster meu-cluster --kubernetes-version v1.28.5 | kubectl apply -f -
```


Quer ver se ele já começou? Roda:

```bash
kubectl get clusters
kubectl get awsclusters
kubectl get machines
kubectl get awsmachines
```