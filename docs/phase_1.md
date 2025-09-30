# Fase 1 — Preparando o `control-plane` no EC2

## 1. Repositório para organização

Construi um repositório no github e deixei ele privado. Isso porque armazenarei as chaves '.pem' de conexão SSH nele.

Após isso, clonei o repositório em minha máquina e criei um esquema de pastas básico: 'ec2/keys'.


## 2. Criação da Instancia EC2

Fui até o console AWS — cujo acesso obtive pelo AWS Academy — e criei uma instancia EC2
    
    Resumo da sua instância:
        • AMI: Ubuntu Server 22.04 LTS (x86_64)
        • Tipo: t2.medium (2 vCPUs, 4 GiB RAM)
        • Nome: capi-bootstrap-ec2
        • Acesso: via SSH com chave capi-bootstrap-key.pem
        • Uso: Servirá como host para o Kind + Cluster API (bootstrap)

## 3. Conexão com Instancia EC2

Após isso, no vscode, abri o terminal no diretório onde estavam as chaves e dei os comandos de conexão com a instancia EC2. Uma conexão usando cliente 'ssh', funcionou no windows pois uso o 'git bash' que é um terminal com os utilitários do Linux.

## 4. Instalando alguns utilitários

Após acessar a máquina, eu instalei alguns utilitários:

    • Docker: necessário para o Kind funcionar, pois ele cria containers Docker que simulam nodes Kubernetes.
    • curl: usado para baixar ferramentas como Kind, kubectl e clusterctl via terminal.
    • git: útil para clonar repositórios e versionar arquivos da prática, como YAMLs do CAPI.

## 5. Configuração do Docker

Após isso, dei comandos para configurar o docker. Em especial, configurei a inicialização dele no boot — irei desligar a máquina eventualmente para evitar gastos no AWS Academy, por isso, para facilitar minha vida, quero que o docker inicialize sempre no boot. Aqui são os comandos:

```
sudo systemctl enable docker          # ativa no boot
sudo systemctl start docker           # inicia agora
sudo usermod -aG docker $USER         # libera uso sem sudo (requer logout/login)
``` 
    


## 6. Instalação de Recursos importantes
    
Após isso, instalei alguns recursos importantes:

    
`kind`
• Para que serve? Cria um mini-cluster Kubernetes local, rodando em containers Docker.
• Qual problema resolve? Te dá um ambiente Kubernetes funcional sem precisar criar várias VMs ou configurar redes reais. Ideal pra testes e labs.
• É o quê? Um utilitário de linha de comando que usa Docker por baixo.

`kubectl`
• Para que serve? É o “controle remoto” do Kubernetes — permite enviar comandos, ver pods, aplicar configs, etc.
• Qual problema resolve? Sem ele, você não consegue interagir com o cluster. Ele é a ponte entre você e o Kubernetes.
• É o quê? Um cliente de linha de comando oficial do Kubernetes.

`clusterctl`
• Para que serve? Inicializa e gerencia o Cluster API — ferramenta que cria e mantém clusters Kubernetes automaticamente.
• Qual problema resolve? Criar clusters Kubernetes manualmente é trabalhoso; o CAPI automatiza isso. E o clusterctl é como você conversa com ele.
• É o quê? Um CLI (utilitário) oficial do Cluster API.

Você usa o Kind para criar rapidamente um cluster Kubernetes local, rodando via Docker — esse cluster é o ambiente onde tudo começa. Dentro dele, você usa o clusterctl para instalar o Cluster API, que é um conjunto de controladores capazes de criar e gerenciar outros clusters Kubernetes. O clusterctl inicializa o CAPI, gera os arquivos de definição do novo cluster e aplica tudo usando o cluster atual como base. Já o kubectl entra como sua ferramenta de controle: é com ele que você inspeciona, aplica ou modifica recursos nos clusters (incluindo o Kind e os gerenciados). Assim, os três se encadeiam: Kind cria o ambiente, clusterctl instala o CAPI, e kubectl interage com tudo.
    
```
# Instalar Kind 
curl -Lo kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 
chmod +x kind && sudo mv kind /usr/local/bin/

# Instalar kubectl 
curl -LO https://dl.k8s.io/release/v1.30.1/bin/linux/amd64/kubectl 
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Instalar clusterctl 
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/latest/download/clusterctl-linux-amd64 -o clusterctl 
chmod +x clusterctl && sudo mv clusterctl /usr/local/bin/
``` 

## 7. Inicializar o Cluster

- kind = Kubernetes IN Docker: ele cria um cluster local dentro de containers Docker.
- Você não instalou um cluster full bare-metal ou com kubeadm.
- O que temos é um ambiente leve e descartável, ideal como "bootstrap cluster" pro Cluster API.

Então até agora, você:

- Instalou Docker.
- Instalou kubectl, kubelet, kubeadm.
- Criou um mini-cluster Kubernetes dentro da EC2 usando kind.

```
kind create cluster --name capi-bootstrap
```

A resposta esperada é :

    Creating cluster "capi-bootstrap" ...
    ✓ Ensuring node image (kindest/node:v1.27.3) 🖼 
    ✓ Preparing nodes 📦  
    ✓ Writing configuration 📜 
    ✓ Starting control-plane 🕹️ 
    ✓ Installing CNI 🔌 
    ✓ Installing StorageClass 💾 
    Set kubectl context to "kind-capi-bootstrap"      
    You can now use your cluster with:

    kubectl cluster-info --context kind-capi-bootstrap

    Thanks for using kind! 😊

**1.  Ensuring node image (kindest/node:v1.27.3)**
→ Baixa (ou reusa) a imagem Docker que simula um nó Kubernetes.

    É literalmente um container que age como se fosse uma VM com K8s! Ele simula um nó K8 completo (control-plane), com todos os binários internos (kubelet, kubeadm, etcd, etc.)

**2. Preparing nodes**
→ Cria e inicializa os containers que representarão os nós do cluster. No caso, nenhum além do `capi-bootstrap-control-plane` foi criado.

**3. Writing configuration**
→ Gera os arquivos de configuração (kubeadm.yaml, etc) pra subir o cluster.

Exemplos:

- `/etc/kubernetes/manifests/kube-apiserver.yaml` → define o pod estático do API server, coração do cluster.

- `/etc/kubernetes/manifests/etcd.yaml` → especifica o etcd, banco chave-valor que guarda o estado do cluster.

- `/etc/kubernetes/manifests/kube-controller-manager.yaml` → orquestra controladores como deployments e replica sets.

- `/etc/kubernetes/manifests/kube-scheduler.yaml` → decide em qual nó cada pod será executado.

- `/etc/kubernetes/pki/ca.crt` → certificado da autoridade raiz, essencial para a autenticação e segurança das comunicações.

**4. Starting control-plane**
→ Inicia o nó principal (control-plane) e cria:

- etcd : banco de dados chave-valor que guarda todo o estado do Kubernetes.
- kube-apiserver : expõe a API do cluster, recebe comandos kubectl e requisições externas.
- kube-controller-manager : mantém a “vida” dos objetos (replicas, endpoints, etc.).
- kube-scheduler : decide em qual nó cada pod novo será executado.

**5. Installing CNI**
→ Instala o Container Network Interface, ou seja, o plugin de rede entre pods.
    
- Sobe kindnet (ou outro plugin de rede). Plugin CNI responsável pela comunicação entre pods.

**6. Installing StorageClass**
→ Cria uma classe de armazenamento padrão para volumes dinâmicos (PVCs).

- Isso permite que você use PersistentVolumeClaim nos seus pods. 

**7. Set kubectl context to "kind-capi-bootstrap"**
→ O kubectl já foi configurado para apontar pro cluster recém-criado.

- Agora você pode usar kubectl get nodes direto, sem mais configs.
- kube-proxy → cria as regras de rede (iptables/ipvs) para expor serviços e balancear tráfego. 
- coredns → serviço DNS interno, traduz nomes de serviço para IPs dentro do cluster.

## 8. Instalação do Cluster API no bootstrap Cluster (Kind)

Com o comando abaixo, estaremos instalando os controladores do CAPI no 'namespace = capi-system'.

```
clusterctl init --infrastructure docker
```

Então, no cluster Kind:

- Instalou o `cert-manager` (para gerenciar certificados).
- Instalou os providers: `cluster-api`, `bootstrap-kubeadm`, `control-plane-kubeadm` e `infrastructure-docker`.
- Cada um foi colocado no seu namespace (`capi-system`, `capi-kubeadm-bootstrap-system`, etc.).

Não são contêineres “soltos” como no Docker, mas controllers do Kubernetes. Cada provider é um controlador que observa objetos CRD (ex: Cluster, Machine) e executa as ações correspondentes (via API/SSH/infra) — ou seja, são processos rodando dentro de um pod. Esse pod, por sua vez, roda dentro de um container Docker hospedado no contêiner-nó `capi-bootstrap-control-plane`. 

Então a hierarquia é:

0. Máquina EC2 → roda Docker.
1. Contêiner Kind (capi-bootstrap-control-plane) → simula um nó Kubernetes.
2. Kubernetes dentro do Kind → sobe pods.
3. Pods → cada provider é um pod (logo, um container) que executa o software do CAPI

**Em essência:** eles são binários Go compilados que implementam controladores, empacotados como imagens Docker, rodando como pods no cluster de bootstrap.

## 9. Gerar o manifesto de um cluster de destino

```
clusterctl generate cluster control-plane \
  --kubernetes-version v1.30.0 \
  --control-plane-machine-count=1 \
  --worker-machine-count=1 \
  | kubectl apply -f -
```


# Situações comuns na prática

## O que é o `kind`?

o `Kind` não é o `control-plane`, ele só te dá um cluster Kubernetes descartável (o bootstrap cluster). Dentro dele você instala os controladores do Cluster API (CAPI). Esses controladores, sim, vão orquestrar a criação de um novo control-plane real (com etcd, kube-apiserver, etc.) nos nós que você indicar. 

Então: Kind = bootstrap cluster; nele roda o CAPI; o CAPI cria e gerencia o control-plane e os workers “de verdade”.


## O que é o `clusterctl`?

O clusterctl é um CLI oficial do Cluster API. Ele serve para inicializar o CAPI dentro de um cluster de bootstrap (ex: Kind), além de gerar manifestos e gerenciar upgrades dos componentes do CAPI.


## O que acontece quando você reinicia a instancia EC2?

É muito o EC2 trocar o IP interno da máquina. Oque acontece? a instancia é trocada? a infra é outra? o EC2 drena? Zonas de disponibilidade.

Após ter configurado a máquina eu a reinicializei. Com os comandos abaixo constatei que estava tudo em pé:

![Container 'Kind' no ar após reiniciar](image/image1.png)
