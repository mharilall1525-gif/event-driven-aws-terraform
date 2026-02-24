# Event-Driven AWS Architecture (Terraform)

## Overview

This project provisions a production-style, event-driven serverless architecture on AWS using Terraform (Infrastructure as Code).

It demonstrates scalable backend design, secure IAM configuration, API integration, and persistent data storage using managed AWS services.

The system allows clients to send messages via an API endpoint, which are processed by AWS Lambda and stored in DynamoDB.

---

## Architecture

**Services Used:**

- AWS Lambda (2 functions)
- Amazon API Gateway (HTTP API)
- Amazon DynamoDB
- IAM Roles & Policies
- Terraform (Infrastructure as Code)

### Flow

1. Client sends a POST request to API Gateway.
2. API Gateway triggers a Lambda function.
3. Lambda processes the request.
4. Data is stored in DynamoDB.
5. API responds with confirmation.

---

## Tech Stack

- Terraform (HCL)
- Python (Lambda runtime)
- AWS (us-east-2 region)
- Git & GitHub

---

## Infrastructure Components

- `main.tf` – Core infrastructure resources
- `provider.tf` – AWS provider configuration
- `variables.tf` – Input variables
- `outputs.tf` – Output values (API endpoint)
- `/lambda` – Primary Lambda function
- `/lambda_ingestion` – Ingestion Lambda function

---

## Deployment

### 1. Initialize Terraform

```bash
terraform init
