#!/bin/bash
# 🌐 Tailscale 组网脚本
# 为 SGC 远征舰队建立安全通信

set -e

NODE_NAME="${1:-$(hostname)}"
echo "🌐 Setting up Tailscale for: $NODE_NAME"

# 检查是否已安装
if command -v tailscale &> /dev/null; then
    echo "✅ Tailscale already installed: $(tailscale version | head -1)"
else
    echo "📦 Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
fi

# 启动服务
echo "🔧 Starting Tailscale..."
sudo systemctl enable --now tailscaled || true

# 检查是否已登录
if tailscale status &> /dev/null; then
    echo "✅ Already logged in to Tailscale"
    echo "📋 Current status:"
    tailscale status
else
    echo ""
    echo "🔑 Please authenticate Tailscale:"
    sudo tailscale up
fi

# 获取IP
TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "unknown")
echo ""
echo "✅ Tailscale IP: $TAILSCALE_IP"

# 配置建议
echo ""
echo "📝 Node configuration:"
echo "  Node Name: $NODE_NAME"
echo "  Tailscale IP: $TAILSCALE_IP"
echo ""

case $NODE_NAME in
    sgc-command|vm-*)
        echo "⭐ This appears to be SGC Command"
        echo "   Role: Command Center"
        echo "   Expected IP: 100.64.x.1"
        ;;
    sg1-primary|zd-pc)
        echo "🚀 This appears to be SG-1 Primary"
        echo "   Role: Heavy Inference Worker"
        echo "   Expected IP: 100.64.x.2"
        ;;
    sg2-recon|desktop-*|gpd-*)
        echo "🔭 This appears to be SG-2 Recon"
        echo "   Role: Mobile Recon Worker"
        echo "   Expected IP: 100.64.x.3"
        ;;
esac

echo ""
echo "🧪 Testing connectivity..."
echo "  Ping SGC Command (100.64.0.1):"
ping -c 1 100.64.0.1 &>/dev/null && echo "    ✅ Reachable" || echo "    ❌ Unreachable"

echo "  Ping SG-1 Primary (100.64.0.2):"
ping -c 1 100.64.0.2 &>/dev/null && echo "    ✅ Reachable" || echo "    ❌ Unreachable"

echo "  Ping SG-2 Recon (100.64.0.3):"
ping -c 1 100.64.0.3 &>/dev/null && echo "    ✅ Reachable" || echo "    ❌ Unreachable"

echo ""
echo "🎉 Tailscale setup complete!"
echo ""
echo "Next steps:"
echo "  1. Update configs with actual Tailscale IPs"
echo "  2. Copy configs to ~/.openclaw/fleet.yaml"
echo "  3. Restart OpenClaw: openclaw gateway restart"
