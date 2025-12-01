# Um historinha para entender

Vou começar contando o que é Kubernetes.

Kubernetes é apenas um banco de dados que armazena 'um estado desejado' e uma API. Além disso, o Kubernetes é realmente um tipo de sistema operacional para serviços distribuídos: sua tarefa principal é a reconciliação contínua – sempre conduzindo o estado real das cargas de trabalho, redes e armazenamento de volta ao estado desejado que você declarou.

Então, temos alguns atores, e vou explicá-los em uma ordem que faça sentido com base na necessidade.

0. **A Aplicação:** É aquilo que você quer 'por no ar' para algum usuário consumir. Antigamente, você compilava e executava ela em uma máquina dentro de um servidor. Atualmente, está na moda quebrar aplicações em componentes menores que implementam só um aspecto, um caso de uso. Isso o que acaba gerando um 'sistema distribuído' — na sessão [Por que o paradigma de microsserviços?](#why-the-microservice-paradigm) falo mais sobre isso.

1. **O tempo de execução:** É necessário um 'lugar' para que sua aplicação execute. Então, você deve ter um ambiente capaz de rodar a aplicação: o `runtime`. Este lugar não é o Kubernetes (muita gente pensa isso). No nosso é um contêiner que segue o `Container Runtime Interface (CRI)`, uma `especificação` do Kubernetes. Esse container será provido por um `Provider`que será o Docker — na sessão [Por que containers?](#por-que-contêineres) falo mais sobre isso.

2. **Kubelet:** Se você escolheu construir esse sistema distribuído, agora precisa coordenar um conjunto potencial de componentes de software, mas percebe que eles não se reconhecem como parte de um sistema maior. Na verdade, o tempo de execução que executa os aplicativos não tem nenhum conhecimento desse contexto maior. É por isso que você precisa de um processo que conecte o aplicativo em tempo de execução ao cluster. Este processo é o `kubelet`, um agente que torna a aplicação verdadeiramente parte do ecossistema.

32. **Nó:** O kubelet disponibiliza a capacidade computacional da máquina para o cluster usando um tempo de execução de contêiner que implementa o CRI. Uma máquina (VM ou bare-metal) que fornece CPU, memória, rede e armazenamento executa o kubelet e se torna parte do cluster. Para enfatizar: um nó é simplesmente uma máquina individual com um kubelet em execução mais um tempo de execução de contêiner.

4. **Pod:** Em certo sentido, um Node está com “capacidade ociosa” aguardando cargas de trabalho. Para usar essa capacidade de forma eficiente, o Kubernetes introduz uma abstração: o `pod`. Um pod é a menor unidade que você pode agendar em um nó. Um pod é um wrapper em torno de um ou mais contêineres que compartilham a mesma rede e armazenamento. Os pods podem executar aplicativos de negócios ou serviços de cluster (como DNS). Eles não são “trabalhos” em si, mas são os blocos de construção básicos que todo o resto programa e gerencia.

até agora, uma distinção importante:
- **Nó** → a máquina, parte do cluster porque um kubelet e um tempo de execução de contêiner estão sendo executados nela; fornece capacidade.
- **Pod** → a abstração da carga de trabalho, a menor unidade programável, agrupando um ou mais contêineres; ele consome a capacidade do nó.


5. **Servidor API:** Este é o hub central. Recebe e expõe o estado interno do cluster como uma API. Ela não “age” por si mesma, mas tudo passa por ela. É apoiado pelo banco de dados `etcd` e implementado como um servidor REST em `Go` . Na verdade, quase todo o Kubernetes é escrito em Go, mais sobre isso em [De onde veio Gollang?](#de-onde-veio-gollang).

6. **Agendador:**


7. **Controladores:** eles observam o servidor da API em busca de objetos de seu interesse (comentarei sobre isso em um momento) e escrevem de volta as alterações no servidor da API para mover o cluster para mais perto do estado desejado.


# Um pouco mais de foco nos Conceitos

- **Cluster** : É o conjunto de máquinas (reais ou simuladas) que rodam o Kubernetes. O cluster possui um control-plane (que orquestra) e nodes (que executam os containers).
- **Recurso (Resource)** : É um tipo de objeto que o Kubernetes entende, como `Pod`, `Service`, `Deployment`. Todo recurso tem um endpoint REST associado na API do cluster.
- **Objeto de Recurso** : É uma instância concreta de um recurso. Um YAML aplicado via kubectl vira um objeto salvo no cluster.
- **Custom Resource (CR)** É um novo tipo de recurso criado por alguém fora do Kubernetes padrão. Exemplo: `Cluster`, `Machine`, `AWSCluster`.
- **Custom Resource Definition (CRD)**: É o "molde" de um Custom Resource. Quando você instala um CRD, o Kubernetes passa a entender aquele novo tipo e expõe um novo endpoint na API.
- **Controller**: É um programa (geralmente rodando como Pod) que observa objetos de determinado tipo e executa ações para alinhar o estado real ao estado desejado.
- **Custom Controller**: É um controller feito sob medida para um Custom Resource. Ele define a lógica do que deve acontecer quando um CR muda.
- **Declaração de Estado**: Ao aplicar um YAML, estou declarando o estado que eu quero no cluster. Os controllers trabalham para que o estado real alcance esse estado desejado.
- **Endpoint (na API)**: É o caminho HTTP exposto pela API do Kubernetes para interagir com um tipo de recurso. Ex: `/api/v1/pods`, `/apis/cluster.x-k8s.io/v1beta1/clusters`.
- **Kubernetes** : É a plataforma que orquestra containers. O Cluster API roda *dentro de um cluster Kubernetes existente*, usando-o como base para criar e gerenciar outros clusters.
- **Kind**: É uma ferramenta que cria um cluster Kubernetes dentro de containers Docker. Serve principalmente para testes, desenvolvimento ou como *cluster bootstrap* onde o Cluster API será instalado.
- **Cluster API**: É um conjunto de CRDs + Controllers que permite criar e gerenciar clusters Kubernetes declarativamente, usando o Kubernetes como plataforma para orquestrar... ele mesmo. É uma camada que estende o Kubernetes com novos recursos e controladores (via CRDs). Com ele, você pode *declarar clusters Kubernetes como YAMLs*, e o CAPI cria, configura e gerencia esses clusters de forma automatizada.
