# O que eu entendi até aqui

Eu estava com um pensamento bastante confuso, sem entender muitas das coisas e o objetivo delas. Mas agora eu sinto que entendi. É bem simples.

O que um cluster kubernetes me entrega? Ele me entrega uma abstração e vários recursos que me ajudam a controlar uma coisa realmente complexa: um sistema distribuído.

Um sistema distribuído é um conjunto de 'ids' e componentes de software que precisam de um ambiente específico para executarem suas atribuições. Eles precisam de uma rede para se comunicarem adequadamente, tanto entre si quanto com o mundo exterior.

O k8s vai te entregar muitas abstrações que de ajudarão a organizar isso com facilidade, mas para além disso, ele te permitirá definir novos recursos, de forma que você pode ampliar a sua gestão. Um exemplo é clássico é quando vocÊ instala um CRD que estende o k8s para criar recursos da AWS.

Com o AWS Load Balancer Controller, por exemplo, você ganha um novo tipo de recurso chamado 'Ingress' que, ao ser aplicado, faz o k8s criar um Load Balancer de verdade na AWS. O mesmo vale para CRDs que criam subnets, security groups, VPCs.

A vantagem disso é que você passa a declarar infraestrutura da AWS como parte do próprio ecossistema Kubernetes, usando os mesmos mecanismos de reconciliação, estado desejado e auto-correção. 

Bom. Com isso ficou claro que vale a pena ter essa capacidade ao seu dispor para gerenciar infraestrutura. Agora, suponha que você está num cluster em que alguém cria um CRD que te dá poder de controlar outros clusters.


# Comandos Usados

Antes 

A primeira coisa que fiz foi criar uma instância EC2 nova. Usei uma imagem `amazon linux` em configurações `t3.medium`.