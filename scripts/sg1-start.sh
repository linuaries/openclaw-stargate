#!/bin/bash
# 🚀 SG1 Team Gateway Startup Script
# Starts all SG1 team members on SGC Command (GPU Workstation)
# 
# Usage:
#   ./sg1-start.sh          # Start all gateways
#   ./sg1-start.sh oneill   # Start specific gateway

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# SG1 Team Configuration
declare -A PROFILES=(
    ["oneill"]="18789"
    ["carter"]="18790"
    ["jackson"]="18791"
    ["tealc"]="18792"
)

declare -A ROLES=(
    ["oneill"]="🎖️ Team Leader"
    ["carter"]="🔬 Developer/Engineer"
    ["jackson"]="📚 Writer/Researcher"
    ["tealc"]="🛡️ Security Specialist"
)

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/../logs"

# Create log directory if not exists
mkdir -p "$LOG_DIR"

# Function to start a single gateway
start_gateway() {
    local profile="$1"
    local port="$2"
    local role="${ROLES[$profile]}"
    local log_file="${LOG_DIR}/gateway-${profile}.log"
    
    echo -e "${CYAN}Starting ${profile^} (${role}) on port ${port}...${NC}"
    
    # Check if port is already in use
    if lsof -i ":$port" > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Port ${port} already in use. ${profile^} may already be running.${NC}"
        echo -e "${YELLOW}   Use './sg1-status.sh' to check status or './sg1-stop.sh ${profile}' to stop.${NC}"
        return 1
    fi
    
    # Start gateway in background
    nohup openclaw gateway start --profile "$profile" --port "$port" > "$log_file" 2>&1 &
    local pid=$!
    
    # Wait briefly and check if process is still running
    sleep 2
    
    if kill -0 "$pid" 2>/dev/null; then
        echo -e "${GREEN}✅ ${profile^} started successfully (PID: ${pid})${NC}"
        echo -e "   Log file: ${log_file}"
        return 0
    else
        echo -e "${RED}❌ ${profile^} failed to start. Check log file: ${log_file}${NC}"
        return 1
    fi
}

# Function to start all gateways
start_all() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           🚀 SG-1 Team Startup Sequence                        ║"
    echo "║              SGC Command - GPU Workstation                     ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    local success_count=0
    local fail_count=0
    
    for profile in oneill carter jackson tealc; do
        port="${PROFILES[$profile]}"
        if start_gateway "$profile" "$port"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
        echo ""
    done
    
    echo -e "${PURPLE}"
    echo "══════════════════════════════════════════════════════════════════"
    echo -e "${NC}"
    echo -e "${GREEN}✅ Started: ${success_count} gateways${NC}"
    
    if [ $fail_count -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Failed/Skipped: ${fail_count} gateways${NC}"
    fi
    
    echo ""
    echo -e "Use ${CYAN}./sg1-status.sh${NC} to check team status"
    echo -e "Use ${CYAN}./sg1-logs.sh${NC} to view logs"
    echo ""
    
    if [ $success_count -eq 4 ]; then
        echo -e "${GREEN}🚀 SG-1, you have a go! Chevron 7 encoded!${NC}"
    fi
}

# Main execution
if [ $# -eq 0 ]; then
    start_all
elif [ $# -eq 1 ]; then
    profile="$1"
    if [[ -v "PROFILES[$profile]" ]]; then
        port="${PROFILES[$profile]}"
        start_gateway "$profile" "$port"
    else
        echo -e "${RED}❌ Unknown profile: ${profile}${NC}"
        echo -e "Available profiles: ${!PROFILES[*]}"
        exit 1
    fi
else
    echo "Usage: $0 [profile]"
    echo "  No argument: Start all SG1 gateways"
    echo "  profile: Start specific gateway (oneill|carter|jackson|tealc)"
    exit 1
fi
