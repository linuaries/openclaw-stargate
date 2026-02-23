#!/bin/bash
# 📊 SGC 远征舰队状态检查脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 节点配置 (可通过环境变量覆盖)
SGC_IP="${SGC_IP:-100.64.0.1}"
ATLANTIS_IP="${ATLANTIS_IP:-100.64.0.2}"
SG2_IP="${SG2_IP:-100.64.0.3}"

OPENCLAW_PORT="${OPENCLAW_PORT:-18789}"
OLLAMA_PORT="${OLLAMA_PORT:-11434}"

echo "🛸 SGC Expedition Fleet Status"
echo "================================"
echo ""

# 函数：检查节点状态
check_node() {
    local name=$1
    local ip=$2
    local role=$3
    local icon=$4
    
    echo -n "$icon $name ($role) @ $ip: "
    
    # 检查网络连通性
    if ! ping -c 1 -W 2 "$ip" >/dev/null 2>&1; then
        echo -e "${RED}🔴 OFFLINE (Network)${NC}"
        return 1
    fi
    
    # 检查OpenClaw服务
    local status_code
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "http://$ip:$OPENCLAW_PORT/status" 2>/dev/null || echo "000")
    
    if [ "$status_code" = "200" ]; then
        # 获取详细信息
        local info
        info=$(curl -s "http://$ip:$OPENCLAW_PORT/status" 2>/dev/null | grep -o '"version":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
        echo -e "${GREEN}🟢 ONLINE${NC} (OpenClaw $info)"
        return 0
    else
        echo -e "${YELLOW}🟡 NETWORK OK${NC} (OpenClaw unavailable, code: $status_code)"
        return 1
    fi
}

# 函数：检查Ollama状态 (仅SG-2)
check_ollama() {
    local name=$1
    local ip=$2
    
    echo -n "   🤖 Ollama @ $ip:$OLLAMA_PORT: "
    
    if curl -s "http://$ip:$OLLAMA_PORT/api/tags" >/dev/null 2>&1; then
        local models
        models=$(curl -s "http://$ip:$OLLAMA_PORT/api/tags" 2>/dev/null | grep -o '"name":"[^"]*"' | wc -l)
        echo -e "${GREEN}✅ Running ($models models)${NC}"
    else
        echo -e "${YELLOW}⚠️  Not running${NC}"
    fi
}

# 函数：检查系统资源
check_resources() {
    local ip=$1
    local node_type=$2
    
    echo "   💻 System Resources:"
    
    if [ "$ip" = "127.0.0.1" ] || [ "$ip" = "localhost" ]; then
        # 本地检查
        local cpu_usage mem_usage
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 || echo "N/A")
        mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}' || echo "N/A")
        
        echo "      CPU: ${cpu_usage}% | Memory: ${mem_usage}%"
        
        # SGC检查GPU
        if [ "$node_type" = "sgc" ] && command -v nvidia-smi &> /dev/null; then
            local gpu_info
            gpu_info=$(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | head -1)
            if [ -n "$gpu_info" ]; then
                echo "      GPU: $gpu_info"
            fi
        fi
    else
        echo "      (Remote resource check not implemented)"
    fi
}

echo "📡 Fleet Nodes Status"
echo "---------------------"

# 检查各节点
check_node "SGC-Command" "$SGC_IP" "本地GPU指挥中心" "⭐" || true
check_node "Atlantis-Expedition" "$ATLANTIS_IP" "国际访问节点" "🌊" || true
check_node "SG-2-Recon" "$SG2_IP" "移动侦察" "🔭" || true

echo ""
echo "🤖 Local Model Status"
echo "---------------------"

# SG-2 Ollama状态
check_ollama "SG-2-Recon" "$SG2_IP" || true

echo ""
echo "📊 Local System Status (SGC Command)"
echo "--------------------------------------"

# 本地系统信息 (假设在SGC上运行)
echo "Hostname: $(hostname)"
echo "Platform: $(uname -s) $(uname -m)"

# CPU信息
if [ -f /proc/cpuinfo ]; then
    local cpu_model
    cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
    echo "CPU: $cpu_model"
fi

# 内存信息
if command -v free &> /dev/null; then
    local mem_total mem_used
    mem_total=$(free -h | grep Mem | awk '{print $2}')
    mem_used=$(free -h | grep Mem | awk '{print $3}')
    echo "Memory: $mem_used / $mem_total"
fi

# GPU信息 (仅SGC)
if command -v nvidia-smi &> /dev/null; then
    echo "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)"
    nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv \
        | tail -n +2 | while read line; do
        echo "      Util: $line"
    done
fi

# OpenClaw状态
echo ""
echo "🔧 OpenClaw Status"
echo "------------------"
if command -v openclaw &> /dev/null; then
    openclaw status 2>&1 | head -20 || echo "OpenClaw status unavailable"
else
    echo "OpenClaw not installed"
fi

echo ""
echo "================================"
echo "🎉 Fleet status check complete!"
echo ""
echo "Architecture:"
echo "  ⭐ SGC Command         - 本地GPU服务器 (指挥中心)"
echo "  🌊 Atlantis Expedition - 腾讯云新加坡 (国际访问)"
echo "  🔭 SG-2 Recon          - GPD MicroPC2 (移动侦察)"
echo ""
echo "To update IP addresses:"
echo "  export SGC_IP=100.64.x.x"
echo "  export ATLANTIS_IP=100.64.x.x"
echo "  export SG2_IP=100.64.x.x"
