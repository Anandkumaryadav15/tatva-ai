# Deployment Guide: Vercel + AWS Services

This guide explains how to deploy **Tatva AI** with the **Frontend on Vercel** and the **Backend & AI Gateway on AWS**.

---

## Architecture Overview

```
 ┌───────────────────────────────────────────────────────────┐
 │                     1. Frontend (Vercel)                  │
 │   - Tatva AI Web UI Dashboard (assets/dashboard)          │
 │   - Configured via vercel.json                            │
 │   - Global CDN, SSL, & Custom Domains                     │
 └─────────────────────────────┬─────────────────────────────┘
                               │ HTTPS API Calls (/v1)
                               ▼
 ┌───────────────────────────────────────────────────────────┐
 │               2. Backend Gateway (AWS Services)           │
 │   - AWS App Runner / ECS Fargate Container (Dockerfile)   │
 │   - Port 8000: OpenAI/Anthropic Compatible Reverse Proxy  │
 └─────────────────────────────┬─────────────────────────────┘
                               │ Native IAM Auth
                               ▼
 ┌───────────────────────────────────────────────────────────┐
 │                   3. AWS Model Layer                      │
 │   - Amazon Bedrock (Claude 3.7, Amazon Nova, Llama 3.2)   │
 │   - AWS Secrets Manager / Parameter Store                 │
 │   - Other Providers (OpenAI, Gemini, Vertex, etc.)        │
 └───────────────────────────────────────────────────────────┘
```

---

## 1. Deploy Frontend on Vercel

The project includes a ready-to-use `vercel.json` configured to serve the **Tatva AI Dashboard** with zero build configuration.

### Steps:
1. Push your repository to **GitHub**:
   ```bash
   git add .
   git commit -m "Deploy Tatva AI on Vercel and AWS"
   git push origin main
   ```
2. Log into [Vercel](https://vercel.com) and click **"Add New Project"**.
3. Select your repository.
4. Click **Deploy**. Vercel will immediately deploy the dashboard with an instant HTTPS URL (e.g. `https://tatva-ai.vercel.app`).

---

## 2. Deploy Backend Gateway on AWS

### Option A: AWS App Runner (Recommended & Simplest)
AWS App Runner provides fully managed container execution, auto-scaling, and managed HTTPS certificates.

1. In the AWS Console, open **AWS App Runner** and click **Create Service**.
2. Select **Source code repository** (connect your GitHub repo) or **Container registry (Amazon ECR)**.
3. Configure settings:
   - **Runtime**: Python 3 or Docker
   - **Port**: `8000`
   - **Start command**: `tatva run --port 8000 --root /app/.exp`
4. Set Environment Variables:
   - `AWS_REGION`: `us-east-1` (or your preferred region)
   - `OPENAI_API_KEY`: Your OpenAI key (if using OpenAI)
   - `ANTHROPIC_API_KEY`: Your Anthropic key (if using Anthropic)
5. Click **Create & Deploy**. AWS will provide a public endpoint (e.g. `https://xxxxxx.us-east-1.awsapprunner.com`).

---

### Option B: Amazon ECS (Fargate)
For enterprise VPC setups:
1. Build and push the Docker image to Amazon ECR:
   ```bash
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <YOUR_AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
   docker build -t tatva-ai-gateway .
   docker tag tatva-ai-gateway:latest <YOUR_AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/tatva-ai:latest
   docker push <YOUR_AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/tatva-ai:latest
   ```
2. Create an ECS Task Definition using Fargate with Port `8000` mapped.
3. Attach an Application Load Balancer (ALB) with an HTTPS listener.

---

## 3. Configuring AWS Bedrock (No API Key Required)

Tatva AI supports **Amazon Bedrock** natively using AWS IAM credentials:

1. Ensure your AWS IAM role has the `bedrock:InvokeModel` and `bedrock:InvokeModelWithResponseStream` permissions.
2. Connect Bedrock inside Tatva AI:
   ```bash
   tatva config gateway provider add aws-bedrock \
     --provider bedrock \
     --region us-east-1 \
     --non-interactive --json

   tatva config gateway alias create claude-bedrock \
     --deployment aws-bedrock:anthropic.claude-3-5-sonnet-20241022-v2:0 \
     --exact-model anthropic.claude-3-5-sonnet-20241022-v2:0 \
     --non-interactive --json

   tatva config gateway grant add default claude-bedrock --non-interactive --json
   ```

Now requests sent to the `claude-bedrock` alias execute directly through your AWS account!
