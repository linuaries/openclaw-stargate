# Azure OpenAI Configuration Guide for OpenClaw

> **Author:** Major Samantha Carter, PhD  
> **Date:** 2026-02-26  
> **Mission:** SGC-Command Technical Documentation

---

## Overview

Azure OpenAI Service provides access to OpenAI's powerful language models (GPT-4o, GPT-4, etc.) through Azure's infrastructure. This guide covers best practices for configuring Azure OpenAI as a provider in OpenClaw, including setup as a fallback LLM.

## Why Azure OpenAI?

- **Enterprise reliability** — Azure's SLA-backed infrastructure
- **Regional deployment** — Choose data residency regions
- **Security** — Azure AD integration, private endpoints
- **Rate limits** — Higher throughput tiers available
- **Cost management** — Azure billing integration, PTU options

---

## Prerequisites

### 1. Azure Resources Required

Before configuring OpenClaw, you need:

| Resource | Purpose | How to Get |
|----------|---------|------------|
| **Azure OpenAI Resource** | The AI service instance | [Azure Portal](https://portal.azure.com/#create/Microsoft.CognitiveServicesOpenAI) |
| **Deployment(s)** | Model instances (gpt-4o, etc.) | Azure OpenAI Studio → Deployments |
| **API Key** | Authentication | Azure Portal → Keys and Endpoint |
| **Endpoint URL** | Base URL for API calls | Azure Portal → Keys and Endpoint |

### 2. Create Azure OpenAI Resource

```bash
# Using Azure CLI (optional)
az cognitiveservices account create \
  --name "openclaw-openai" \
  --resource-group "your-rg" \
  --kind "OpenAI" \
  --sku "S0" \
  --location "eastus"
```

### 3. Deploy a Model

In Azure OpenAI Studio:
1. Go to **Deployments** → **Create new deployment**
2. Select model (recommended: `gpt-4o` or `gpt-4o-mini`)
3. Name your deployment (e.g., `gpt-4o-openclaw`)
4. Note the **deployment name** — you'll need it for configuration

---

## Configuration

### Option A: Environment Variables (Recommended)

The simplest approach — set environment variables and let OpenClaw auto-configure:

```bash
# In ~/.openclaw/.env or shell environment
AZURE_OPENAI_API_KEY="your-api-key-here"
AZURE_OPENAI_ENDPOINT="https://your-resource.openai.azure.com"
AZURE_OPENAI_DEPLOYMENT="gpt-4o-openclaw"  # Your deployment name
```

### Option B: Custom Provider Configuration

For full control, configure Azure OpenAI as a custom provider in `~/.openclaw/openclaw.json`:

```json5
{
  env: {
    AZURE_OPENAI_API_KEY: "your-api-key-here",
  },
  
  models: {
    mode: "merge",
    providers: {
      azure: {
        // Azure OpenAI endpoint (without /openai/deployments/... path)
        baseUrl: "https://your-resource.openai.azure.com",
        
        // API key from env
        apiKey: "${AZURE_OPENAI_API_KEY}",
        
        // Use OpenAI-compatible API mode
        api: "openai-completions",
        
        // Model catalog
        models: [
           {
            "id": "gpt-5.3-codex",
            "name": "gpt-5.3-codex",
            "reasoning": true,
            "input": [
              "text",
              "image"
            ],
            "cost": {
              "input": 0.03,
              "output": 0.06
            },
            "contextWindow": 8000,
            "maxTokens": 4096
          }
        ],
      },
    },
  },
  
  agents: {
    defaults: {
      model: {
        primary: "zai/glm-5",  // Your current primary
        fallbacks: [
          "azure/gpt-5.3-codex",       // Azure as fallback
          "moonshot/kimi-k2.5", // Additional fallback
        ],
      },
    },
  },
}
```

### Option C: LiteLLM Proxy (Advanced)

For unified gateway management with cost tracking:

```yaml
# litellm config.yaml
model_list:
  - model_name: azure-gpt-4o
    litellm_params:
      model: azure/gpt-4o
      api_key: os.environ/AZURE_OPENAI_API_KEY
      api_base: https://your-resource.openai.azure.com
      api_version: "2024-12-01-preview"
```

Then configure OpenClaw to use LiteLLM:

```json5
{
  agents: {
    defaults: {
      model: {
        primary: "litellm/azure-gpt-4o",
      },
    },
  },
}
```

---

## Azure OpenAI URL Structure

Understanding the URL format is critical:

```
Base Endpoint: https://<resource-name>.openai.azure.com

Full Chat Completion URL:
https://<resource-name>.openai.azure.com/openai/deployments/<deployment-name>/chat/completions?api-version=<api-version>

Example:
https://openclaw-openai.openai.azure.com/openai/deployments/gpt-4o-deployment/chat/completions?api-version=2024-12-01-preview
```

### Key Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `<resource-name>` | Your Azure OpenAI resource name | `openclaw-openai` |
| `<deployment-name>` | Model deployment name | `gpt-4o-deployment` |
| `<api-version>` | API version (required) | `2024-12-01-preview` |

---

## Authentication

### Method 1: API Key (Simplest)

```bash
# Header format
api-key: <your-api-key>
```

In OpenClaw config:
```json5
{
  models: {
    providers: {
      azure: {
        headers: {
          "api-key": "${AZURE_OPENAI_API_KEY}",
        },
      },
    },
  },
}
```

### Method 2: Azure AD (Recommended for Enterprise)

For Azure AD authentication:

```bash
# Install Azure CLI and login
az login

# Get token
TOKEN=$(az account get-access-token --resource https://cognitiveservices.azure.com --query accessToken -o tsv)
```

In OpenClaw:
```json5
{
  models: {
    providers: {
      azure: {
        headers: {
          "Authorization": "Bearer ${AZURE_AD_TOKEN}",
        },
      },
    },
  },
}
```

---

## Best Practices

### 1. Fallback Configuration

Configure Azure OpenAI as a fallback to handle rate limits and timeouts:

```json5
{
  agents: {
    defaults: {
      model: {
        primary: "zai/glm-5",
        fallbacks: [
          "azure/gpt-4o",          // First fallback
          "moonshot/kimi-k2.5",    // Second fallback
        ],
      },
    },
  },
}
```

### 2. Multiple Deployments for High Availability

Create multiple deployments in different regions:

```json5
{
  models: {
    providers: {
      azure: {
        baseUrl: "https://openclaw-openai-eastus.openai.azure.com",
        // ... config ...
      },
      azure-backup: {
        baseUrl: "https://openclaw-openai-westus.openai.azure.com",
        // ... config ...
      },
    },
  },
  agents: {
    defaults: {
      model: {
        fallbacks: [
          "azure/gpt-4o",
          "azure-backup/gpt-4o",
        ],
      },
    },
  },
}
```

### 3. Rate Limit Handling

OpenClaw automatically handles rate limits through:
- **Auth profile rotation** — Multiple API keys if configured
- **Cooldown backoff** — Exponential backoff on rate limits
- **Model fallback** — Switch to next model in fallback chain

Configure cooldowns:

```json5
{
  auth: {
    cooldowns: {
      billingBackoffHours: 5,
      billingMaxHours: 24,
      failureWindowHours: 24,
    },
  },
}
```

### 4. Cost Management

| Strategy | Configuration |
|----------|---------------|
| **Use GPT-4o-mini for simple tasks** | Set as default, GPT-4o as fallback |
| **PTU (Provisioned Throughput)** | Reserve capacity for predictable workloads |
| **Token limits** | Set `maxTokens` appropriately per model |
| **Monitor usage** | Azure Cost Management + OpenClaw `/status` |

### 5. Security Recommendations

| Practice | Implementation |
|----------|----------------|
| **Use Azure Key Vault** | Store API keys securely |
| **Enable Private Endpoints** | Restrict network access |
| **Azure AD Authentication** | Replace API keys with managed identity |
| **RBAC** | Limit who can access the OpenAI resource |
| **Audit Logs** | Enable Azure Monitor diagnostics |

---

## Model Selection Guide

| Model | Best For | Context | Cost Tier |
|-------|----------|---------|-----------|
| **gpt-4o** | Complex reasoning, multi-modal | 128K | High |
| **gpt-4o-mini** | Fast, cost-effective tasks | 128K | Low |
| **gpt-4-turbo** | Legacy applications | 128K | Medium |
| **gpt-35-turbo** | Simple chat, high volume | 16K | Lowest |

### Recommended Configuration for Stargate Fleet

```json5
{
  agents: {
    defaults: {
      model: {
        // Primary: GLM-5 (cost-effective, good for Chinese/English)
        primary: "zai/glm-5",
        
        // Fallbacks in priority order
        fallbacks: [
          "azure/gpt-4o",           // Azure for reliability
          "moonshot/kimi-k2.5",     // Kimi for long context
          "openai/gpt-4o-mini",     // OpenAI direct as last resort
        ],
      },
      
      // Image model (if needed)
      imageModel: {
        primary: "azure/gpt-4o",    // Azure has good vision
      },
    },
  },
}
```

---

## Troubleshooting

### Common Issues

| Error | Cause | Solution |
|-------|-------|----------|
| `401 Unauthorized` | Invalid API key | Verify key in Azure Portal |
| `404 Not Found` | Wrong endpoint/deployment | Check resource name and deployment |
| `429 Too Many Requests` | Rate limit exceeded | Add fallbacks, increase TPM quota |
| `400 Bad Request` | Invalid API version | Update `api-version` parameter |

### Debug Commands

```bash
# Check model status
openclaw models status

# Test Azure connection
curl -X POST "https://<resource>.openai.azure.com/openai/deployments/<deployment>/chat/completions?api-version=2024-12-01-preview" \
  -H "api-key: $AZURE_OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello"}],"max_tokens":10}'

# Check OpenClaw logs
openclaw logs --tail 50
```

---

## Quick Reference

### Environment Variables

```bash
# Required
AZURE_OPENAI_API_KEY="your-key"
AZURE_OPENAI_ENDPOINT="https://your-resource.openai.azure.com"
AZURE_OPENAI_DEPLOYMENT="gpt-4o-deployment"

# Optional
AZURE_OPENAI_API_VERSION="2024-12-01-preview"
```

### Minimal Config

```json5
{
  env: {
    AZURE_OPENAI_API_KEY: "your-key",
  },
  models: {
    providers: {
      azure: {
        baseUrl: "https://your-resource.openai.azure.com",
        apiKey: "${AZURE_OPENAI_API_KEY}",
        api: "openai-completions",
        params: { "api-version": "2024-12-01-preview" },
        models: [{ id: "gpt-4o", name: "GPT-4o" }],
      },
    },
  },
  agents: {
    defaults: {
      model: { fallbacks: ["azure/gpt-4o"] },
    },
  },
}
```

---

## References

- [Azure OpenAI Service Documentation](https://learn.microsoft.com/en-us/azure/ai-services/openai/)
- [OpenClaw Model Providers](https://docs.openclaw.ai/concepts/model-providers)
- [OpenClaw Model Failover](https://docs.openclaw.ai/concepts/model-failover)
- [Azure OpenAI REST API Reference](https://learn.microsoft.com/en-us/azure/ai-services/openai/reference)

---

*"The math checks out, sir. Azure OpenAI is a solid choice for a fallback provider."* — Maj. Samantha Carter
