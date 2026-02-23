#!/bin/bash
# 🚀 Ollama 安装脚本
# 
# 注意: 此脚本仅用于 SG-2 Recon (GPD MicroPC2)
# SGC Command 和 Atlantis Expedition 使用纯 API 模式，无需安装Ollama

set -e

PROFILE="${1:-recon}"

# 检测当前节点类型
HOSTNAME=$(hostname)

# 检查是否在SGC Command上运行 (ZD-PC)
if echo "$HOSTNAME" | grep -qi "zd-pc\|ZD-PC"; then
    echo "ℹ️  检测到 SGC Command (本地GPU服务器)"
    echo "   SGC Command 使用纯 API 模式 (Zai/GLM-5, Moonshot/K2.5)"
    echo "   利用本地GPU进行图像/声音处理，而非LLM推理"
    echo ""
    echo "   如需在SGC上安装Ollama用于其他用途，请使用:"
    echo "     $0 --force-sgc"
    echo ""
    
    if [ "$2" != "--force-sgc" ]; then
        echo "✅ SGC Command 配置完成 (API模式 + GPU计算)"
        exit 0
    fi
    
    echo "⚠️  强制在SGC Command上安装Ollama..."
fi

# 检查是否在Atlantis上运行
if echo "$HOSTNAME" | grep -qi "opencloudos\|vm-0-2"; then
    echo "ℹ️  检测到 Atlantis Expedition (腾讯云新加坡)"
    echo "   Atlantis 使用纯 API 模式 (Moonshot/K2.5, Zai/GLM-5)"
    echo "   作为国际访问节点，无需本地模型"
    echo ""
    echo "   如需在Atlantis上安装Ollama，请使用:"
    echo "     $0 --force-atlantis"
    echo ""
    
    if [ "$2" != "--force-atlantis" ]; then
        echo "✅ Atlantis Expedition 配置完成 (API模式)"
        exit 0
    fi
    
    echo "⚠️  强制在Atlantis上安装Ollama..."
fi

echo "🚀 Installing Ollama for profile: $PROFILE"

# 检查系统
if ! command -v curl &> /dev/null; then
    echo "❌ curl not found. Installing..."
    sudo apt-get update && sudo apt-get install -y curl
fi

# 安装 Ollama
echo "📦 Installing Ollama..."
if command -v ollama &> /dev/null; then
    echo "✅ Ollama already installed: $(ollama --version)"
else
    curl -fsSL https://ollama.com/install.sh | sh
    echo "✅ Ollama installed"
fi

# 启动服务
echo "🔧 Configuring Ollama service..."
sudo systemctl enable ollama || true
sudo systemctl start ollama || true

# 等待服务启动
sleep 2

# 检查服务状态
if ! systemctl is-active --quiet ollama; then
    echo "⚠️  Ollama service failed to start. Trying manual start..."
    ollama serve &
    sleep 3
fi

# 根据配置拉取模型
echo "📥 Pulling models for profile: $PROFILE"

if [ "$PROFILE" = "primary" ]; then
    echo "🚀 Primary profile: Heavy inference models"
    echo "   ⚠️  注意: SGC/Atlantis建议使用 API 模式而非本地模型"
    echo ""
    
    # 主力模型 - 14B Qwen
    echo "  ⬇️  Qwen2.5-14B (主力模型)..."
    ollama pull qwen2.5:14b || echo "⚠️  Failed to pull qwen2.5:14b"
    
    # 代码模型 - 6.7B DeepSeek
    echo "  ⬇️  DeepSeek-Coder-6.7B (代码专用)..."
    ollama pull deepseek-coder:6.7b || echo "⚠️  Failed to pull deepseek-coder:6.7b"
    
    # 快速模型 - 8B Llama
    echo "  ⬇️  Llama-3.1-8B (快速响应)..."
    ollama pull llama3.1:8b || echo "⚠️  Failed to pull llama3.1:8b"
    
    # 可选大模型
    echo "  ⬇️  DeepSeek-Coder-33B (大模型模式)..."
    ollama pull deepseek-coder:33b || echo "⚠️  Failed to pull deepseek-coder:33b"
    
elif [ "$PROFILE" = "recon" ]; then
    echo "🔭 Recon profile: Lightweight models (for SG-2 Recon)"
    
    # 超轻量 - Phi-3
    echo "  ⬇️  Phi-3-Mini (超轻量)..."
    ollama pull phi3:mini || echo "⚠️  Failed to pull phi3:mini"
    
    # 中文轻量 - Qwen 1.8B
    echo "  ⬇️  Qwen2.5-1.8B (中文优化)..."
    ollama pull qwen2.5:1.8b || echo "⚠️  Failed to pull qwen2.5:1.8b"
    
    # 极低资源 - TinyLlama
    echo "  ⬇️  TinyLlama-1.1B (紧急备用)..."
    ollama pull tinyllama:1.1b || echo "⚠️  Failed to pull tinyllama:1.1b"
    
else
    echo "❌ Unknown profile: $PROFILE"
    echo "Usage: $0 [recon|primary --force-sgc|--force-atlantis]"
    exit 1
fi

# 验证安装
echo ""
echo "✅ Installation complete!"
echo "📋 Installed models:"
ollama list

echo ""
echo "🧪 Testing inference..."
echo "Hello" | ollama run $([ "$PROFILE" = "primary" ] && echo "qwen2.5:14b" || echo "qwen2.5:1.8b") --verbose 2>/dev/null || echo "⚠️  Test failed, but models are installed"

echo ""
echo "🎉 Done!"
echo ""

if [ "$PROFILE" = "primary" ]; then
    echo "⚠️  提醒: 建议使用 API 模式而非本地模型"
    echo "   - SGC Command: API + GPU计算"
    echo "   - Atlantis: 纯API模式"
    echo ""
    echo "Quick test commands:"
    echo "  ollama run qwen2.5:14b       # 主力模型"
    echo "  ollama run deepseek-coder:6.7b  # 代码模型"
else
    echo "SG-2 Recon (GPD) 配置完成!"
    echo ""
    echo "Quick test commands:"
    echo "  ollama run qwen2.5:1.8b      # 中文轻量"
    echo "  ollama run phi3:mini         # 超轻量"
    echo "  ollama run tinyllama:1.1b    # 极低资源"
fi
