#!/bin/bash
# Azure OpenAI Setup Script for OpenClaw
# Author: Maj. Samantha Carter, SGC-Command
# Usage: ./setup-azure-openai.sh

set -e

echo "🔬 Azure OpenAI Configuration Setup"
echo "===================================="
echo ""

# Check for existing .env
ENV_FILE="$HOME/.openclaw/.env"
CONFIG_FILE="$HOME/.openclaw/openclaw.json"

# Prompt for Azure OpenAI details
echo "Please provide your Azure OpenAI details:"
echo ""

read -p "Azure OpenAI Resource Name (e.g., openclaw-openai): " RESOURCE_NAME
read -p "Deployment Name (e.g., gpt-4o-deployment): " DEPLOYMENT_NAME
read -sp "API Key: " API_KEY
echo ""
read -p "API Version (default: 2024-12-01-preview): " API_VERSION
API_VERSION=${API_VERSION:-"2024-12-01-preview"}

# Validate inputs
if [[ -z "$RESOURCE_NAME" || -z "$DEPLOYMENT_NAME" || -z "$API_KEY" ]]; then
    echo "❌ Error: Resource name, deployment name, and API key are required."
    exit 1
fi

# Construct endpoint
ENDPOINT="https://${RESOURCE_NAME}.openai.azure.com"

echo ""
echo "📝 Configuration Summary:"
echo "  Endpoint: $ENDPOINT"
echo "  Deployment: $DEPLOYMENT_NAME"
echo "  API Version: $API_VERSION"
echo ""

read -p "Proceed with configuration? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

# Update .env file
echo ""
echo "🔧 Updating environment variables..."

mkdir -p "$(dirname "$ENV_FILE")"

# Check if .env exists and has Azure config
if [[ -f "$ENV_FILE" ]]; then
    # Remove existing Azure config
    sed -i '/^AZURE_OPENAI_/d' "$ENV_FILE"
fi

# Append new config
cat >> "$ENV_FILE" << EOF

# Azure OpenAI Configuration (added by setup script)
AZURE_OPENAI_API_KEY="$API_KEY"
AZURE_OPENAI_ENDPOINT="$ENDPOINT"
AZURE_OPENAI_DEPLOYMENT="$DEPLOYMENT_NAME"
AZURE_OPENAI_API_VERSION="$API_VERSION"
EOF

echo "✅ Environment variables updated in $ENV_FILE"

# Test connection
echo ""
echo "🔍 Testing Azure OpenAI connection..."

TEST_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "${ENDPOINT}/openai/deployments/${DEPLOYMENT_NAME}/chat/completions?api-version=${API_VERSION}" \
    -H "api-key: $API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"messages":[{"role":"user","content":"Hello"}],"max_tokens":10}')

if [[ "$TEST_RESPONSE" == "200" ]]; then
    echo "✅ Connection successful! Azure OpenAI is properly configured."
elif [[ "$TEST_RESPONSE" == "401" ]]; then
    echo "❌ Authentication failed. Please check your API key."
elif [[ "$TEST_RESPONSE" == "404" ]]; then
    echo "❌ Endpoint not found. Please check your resource name and deployment."
else
    echo "⚠️  Unexpected response code: $TEST_RESPONSE"
    echo "   Please verify your configuration manually."
fi

# Next steps
echo ""
echo "📋 Next Steps:"
echo "  1. Review the config template:"
echo "     cat /home/aistudio/openclaw-stargate/configs/azure-openai-provider.json5"
echo ""
echo "  2. Add Azure provider to your OpenClaw config:"
echo "     openclaw config edit"
echo ""
echo "  3. Set Azure as a fallback model:"
echo "     openclaw models fallbacks add azure/gpt-4o"
echo ""
echo "  4. Verify configuration:"
echo "     openclaw models status"
echo ""
echo "  5. Restart gateway to apply changes:"
echo "     openclaw gateway restart"
echo ""
echo "📚 Documentation: /home/aistudio/openclaw-stargate/docs/AZURE-OPENAI.md"
echo ""
echo "Done! 🔬"
