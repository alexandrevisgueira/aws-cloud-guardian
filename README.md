# AWS Cloud Guardian

## Visão Geral

Projeto serverless desenvolvido na AWS utilizando Terraform, API Gateway, AWS Lambda, S3, IAM e CloudWatch para processamento de requisições HTTP via webhook.

O projeto foi criado com foco em automação cloud, infraestrutura como código (IaC), observabilidade e arquitetura serverless, aplicando boas práticas de segurança e troubleshooting real em ambiente AWS.

---

## Arquitetura

Fluxo da aplicação:

Cliente HTTP/Webhook
↓
API Gateway
↓
AWS Lambda
↓
CloudWatch Logs

Infraestrutura provisionada com Terraform.

---

## Stack Utilizada

- Terraform
- AWS Lambda
- API Gateway
- Amazon S3
- IAM
- CloudWatch
- Python 3.11
- PowerShell
- Git/GitHub

---

## Funcionalidades

- Endpoint HTTP serverless
- Processamento de eventos via webhook
- Integração API Gateway + Lambda
- Logs centralizados no CloudWatch
- Deploy automatizado com Terraform
- Estrutura preparada para automações futuras
- Arquitetura baseada em serviços gerenciados da AWS

---

## Segurança Aplicada

- Uso de `.env`
- Uso de `.gitignore`
- Proteção contra versionamento de secrets
- Controle de permissões com IAM
- Princípio de menor privilégio
- Separação entre código e infraestrutura
- Monitoramento de erros via CloudWatch

---

## Principais Desafios Resolvidos

Durante o desenvolvimento foram resolvidos problemas reais de cloud e infraestrutura:

- Permissões IAM (`AccessDenied`)
- Configuração do API Gateway
- Integração API Gateway + Lambda
- Erro de roteamento HTTP (`Not Found`)
- Limite de tamanho do pacote Lambda
- Dependências Python na Lambda
- Debugging via CloudWatch Logs
- Diferença entre eventos S3 e API Gateway
- Empacotamento da função serverless

---

## Deploy da Infraestrutura

Inicialização do Terraform:

```bash
terraform init
