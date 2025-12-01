# CAPI Lab EC2

Para montar o ambiente e provisionar a infraestrutura com Terraform + AWS, é necessário instalar:

---

## **Terraform**  
Download: https://developer.hashicorp.com/terraform/downloads  

O Terraform é uma ferramenta de **Infrastructure as Code (IaC)**.  
Ele permite declarar toda a infraestrutura (EC2, VPC, Security Groups, Key Pairs etc.) em arquivos `.tf` e criar tudo de forma automatizada.  
Domínio: **infraestrutura** → ele conversa direto com a AWS para criar recursos.

---

## **AWS CLI**  
Download: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html  

O AWS CLI é a ferramenta oficial para interagir com a AWS pelo terminal.  
É usado para autenticar, checar credenciais, testar permissões e validar se sua conta está configurada corretamente antes do Terraform rodar.  
Domínio: **gerenciamento e autenticação** → fornece as credenciais e perfis que o Terraform usará.

---
