# Fase 2 — Preparando o `edge-node` no WSL2

Por questões de praticidade, usarei meu windows desktop como um simulacro desse 'poder computacional na borda'. Mas o windows é um sistema operacional pouco amigável ao fim que estamos pretendendo. Uma alternativa melhor seria um kernel linux e, felizmente, podemos ter essa benécie usando o WSL2 — Windows Subsystem for Linux, na versão 2.

Com isso, transformamos meu desktop em um ambiente apto para receber a criação de um cluster kubernets, que será provisionado remotamente via Cluster API.

## 1. Instalação do Ubuntu no WSL

A primeira coisa é garantir que existe uma distribuição linux no WSL. No meu caso eu instalei um 'Ubuntu'. Isto é, eu já tenho o WSL instalado e através dele eu invoquei:

```
wsl --install -d "Ubuntu-22.04"
```

Após instalar, eu dou o comando

```
wsl --list --verbose
```
Só para verificar se está instalado corretamente. Rode também, dentro da máquina, esse comando:

```
lsb_release -a
```

A resposta deve ser:

    No LSB modules are available.
    Distributor ID: Ubuntu
    Description:    Ubuntu 22.04.5 LTS
    Release:        22.04
    Codename:       jammy
    

## 2. Configurando Ubuntu para ser Borda

Entrando na distribuição com `wsl -d Ubuntu`, você estará em uma máquina linux, basicamente. 

O objetivo aqui é transformar a máquina local (WSL2 Ubuntu) em um ambiente apto a receber a criação de um cluster Kubernets, provisionado remotamente via Cluster API a partir do EC2.

Aqui é interessante salientar o que o Cluster API não fará, ele não irá preparar uma máquina para receber um Cluster Kubernets. Na verdade, existem alguns pré-requisitos que essa máquina precisa cumprir:

- Ter o sistema operacional compatível (como Ubuntu ou outra distro Linux) → É onde estamos.
- Ter o Docker ou containerd instalado
- Ter o `kubeadm`, `kubelet` e `kubectl` instalados
- Ter o SSH habilitado e acessível remotamente
- Estar acessível via rede/VPN a partir do nó de controle (EC2)

Esses requisitos refletem que o CAPI atua **a partir** de um ambiente operacionalmente pronto, não em nível de bare-metal provisioning.

Instalar o docker é a primeira coisa:

```
sudo apt update && sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
sudo systemctl enable docker
```

• O que é systemctl?

É a ferramenta de gerenciamento do systemd, que cuida dos serviços no Linux.
    • O que esse comando faz?

Diz ao Linux: “inicie o Docker automaticamente toda vez que o sistema for ligado”.
        
sudo usermod -aG docker $USER
    • O que é usermod?

Um utilitário para modificar configurações de usuários no Linux.
    • O que esse comando faz?

Adiciona seu usuário ao grupo docker, permitindo rodar docker sem sudo.
        


## 3. Configurando algumas coisas para instalar Kubernetes

Agora sim, instalando coisas do Kubernets

```
sudo apt update && sudo apt install -y apt-transport-https ca-certificates curl
```

**→ Efeito:**
Atualiza a lista de pacotes e instala ferramentas necessárias para comunicação HTTPS segura (apt-transport-https, ca-certificates, curl). Pré-requisito básico para adicionar repositórios externos.

```
sudo mkdir -p /etc/apt/keyrings
```
        
**→ Efeito:**
Cria o diretório onde o APT espera encontrar chaves GPG modernas no Ubuntu 22.04+ (/etc/apt/keyrings), se ainda não existir.

```
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```
        
**→ Efeito:**
Baixa a chave pública do repositório do Kubernetes.
Converte com gpg --dearmor para o formato binário .gpg.
Salva no local padrão /etc/apt/keyrings/kubernetes-apt-keyring.gpg.
        

```
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

**→ Efeito:**
Adiciona o repositório oficial do Kubernetes v1.30 à lista de fontes do APT, usando a chave .gpg para verificação segura. Esse é o repositório correto que funcionou com Ubuntu 22.04.

```
sudo apt update
```
        
**→ Efeito:**
Atualiza a lista de pacotes novamente, agora incluindo o repositório do Kubernetes.
Confirmado por você: não deu erro de GPG nem 404 — o repositório está funcionando.


## 4. instalar e validar os binários essenciais (kubeadm, kubelet, docker/ssh) no WSL2.    

Agora que temos a máquina pronta para receber e instalar as coisas, vamos de fato instalar elas.

`kubectl` é a ferramenta de linha de comando (CLI) que o usuário usa para interagir com o cluster Kubernetes: listar pods, criar deployments, aplicar arquivos YAML, etc. Ele se comunica com a API Server do cluster usando o arquivo kubeconfig.

`kubeadm`	Inicializar ou adicionar nós a um cluster.	Ele só é usado no início. Depois do cluster criado, ele não participa mais.

`kubelet`	Executar pods e manter eles rodando no nó.	Ele é o "motor de execução" do Kubernetes. Precisa rodar em cada máquina do cluster.

`kubectl`	Interagir com o cluster via API Server.	É um cliente CLI, que pode rodar de qualquer lugar (mesmo fora do cluster).


vamos instalar todos eles de uma vez só, já que vamos:
- Criar um cluster local via kubeadm
- Gerenciar via kubectl
- Rodar os pods com kubelet

```
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```
        
**→ Efeito:**
Impede que esses pacotes sejam atualizados automaticamente (mantém a versão estável usada no seu setup).

```
kubeadm version
kubelet --version
kubectl version --client
docker --version
ssh -V
```
        
**→ Efeito:**
Verifica se o kubeadm foi instalado corretamente e exibe sua versão.

![confirmação de instalação das instalações](image/image2.png)





