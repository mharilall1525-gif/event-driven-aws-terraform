# Event-Driven AWS Architecture (Terraform)

## Overview

This project provisions a production-style event-driven serverless architecture on AWS using Terraform.

The system demonstrates Infrastructure as Code (IaC), scalable event processing, and secure resource provisioning using AWS managed services.

---

## Architecture

The architecture includes:

- **AWS Lambda (Python 3.9)** – Serverless compute for request processing  
- **API Gateway (HTTP API)** – Public HTTP endpoint  
- **Amazon DynamoDB** – NoSQL database for message storage  
- **IAM Roles & Policies** – Secure permission management  
- **Terraform** – Infrastructure as Code provisioning  

---

## How It Works

1. API Gateway receives an HTTP request.
2. The request triggers a Lambda function.
3. Lambda processes the payload.
4. The message is stored in DynamoDB.
5. A success response is returned to the client.

This design demonstrates:

- Stateless serverless execution  
- Managed database storage  
- Infrastructure automation  
- Cloud-native architecture principles  

---

## Infrastructure as Code

All resources are defined using Terraform.

### Key Terraform Components

- `main.tf` – Core AWS resources  
- `provider.tf` – AWS provider configuration  
- `variables.tf` – Parameterized inputs  
- `outputs.tf` – Deployment outputs  
- `.gitignore` – Excludes Terraform state and artifacts  

---

## Deployment

```bash
terraform init
terraform plan
terraform apply
