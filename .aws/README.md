# Sobre o uso da AWS para práticas

##  Configuração das credenciais AWS

Antes de usar o Terraform, o AWS CLI precisa saber qual credencial usar. Você deve manter um arquivo próprio contento as credenciais `accessKeys` em `.aws/credentials`. Elas podem ser geradas no console do IAM para o usuário em questão. Salve essas credenciais no padrão da :

```ini
[default]
aws_access_key_id = SUA_KEY
aws_secret_access_key = SUA_SECRET
```

Como esse arquivo não está no local padrão do AWS CLI, é obrigatório informar manualmente onde ele está. Isso é feito com a variável de ambiente: `AWS_SHARED_CREDENTIALS_FILE`. Essa variável é usada pelo AWS CLI e ao Terraform:   **“Use este arquivo aqui como origem das credenciais.”**

> **NOTA:** Ela vale apenas no terminal e no diretório onde foi criada. Se você abrir outro terminal ou sequer trocar de diretório, ela perderá efeito.

```bash
cd aws-k8s-lab-1/terraform
export AWS_SHARED_CREDENTIALS_FILE="../../.aws/credentials"
```

Verifique se o AWS CLI está lendo esse arquivo corretamente:

```bash
aws sts get-caller-identity
```
Isso deve produzir a seguinte saída:

```json
{
    "UserId": "<User ID>",
    "Account": "<Account Number>",
    "Arn": "<Arn da Identidade>"
}
```

> **ATENÇÃO**: se você tem a prática de utilizar AWS CLI, avalie bem o retorno do sts para ter certeza de estar apontando para account correta. A depender das permissões que você tiver, a partir de agora criará diversos recursos na AWS.