#!/bin/bash
# 🚀 SG1 Team Gateway Startup Script
# Starts all SG1 team members via systemd services
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
    ["carter"]="18799"
    ["jackson"]="18809"
    ["tealc"]="18819"
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
SYSTEMD_DIR="/root/.config/systemd/user"

# Create log directory if not exists
mkdir -p "$LOG_DIR"

# Function to ensure gateway mode is set to local
ensure_gateway_config() {
    local profile="$1"
    local state_dir="/root/.openclaw-${profile}"

    # Ensure profile directory exists
    if [ ! -d "$state_dir" ]; then
        echo -e "${YELLOW}   Creating profile directory: $state_dir${NC}"
        mkdir -p "$state_dir"
    fi

    # Set gateway mode to local
    if ! openclaw --profile "$profile" config get gateway.mode 2>/dev/null | grep -q "local"; then
        echo -e "${YELLOW}   Setting gateway.mode=local for ${profile^}${NC}"
        openclaw --profile "$profile" config set gateway.mode local >/dev/null 2>&1 || true
    fi
}

# Function to install systemd service if needed
install_service() {
    local profile="$1"
    local port="$2"
    local service_file="${SYSTEMD_DIR}/openclaw-gateway-${profile}.service"

    # Install service if not exists
    if [ ! -f "$service_file" ]; then
        echo -e "${YELLOW}   Installing systemd service for ${profile^}...${NC}"
        openclaw --profile "$profile" gateway install >/dev/null 2>&1 || true

        # Fix port in service file (openclaw bug: uses 18789 for all)
        if [ -f "$service_file" ]; then
            sed -i "s/--port 18789/--port $port/g" "$service_file"
            sed -i "s/OPENCLAW_GATEWAY_PORT=18789/OPENCLAW_GATEWAY_PORT=$port/g" "$service_file"
        fi

        # Reload systemd
        systemctl --user daemon-reload >/dev/null 2>&1 || true
    fi
}

# Function to start a single gateway
start_gateway() {
    local profile="$1"
    local port="$2"
    local role="${ROLES[$profile]}"
    local service_name="openclaw-gateway-${profile}.service"

    echo -e "${CYAN}Starting ${profile^} (${role}) on port ${port}...${NC}"

    # Ensure config and service exist
    ensure_gateway_config "$profile"
    install_service "$profile" "$port"

    # Check if already active
    if systemctl --user is-active --quiet "$service_name"; then
        echo -e "${YELLOW}⚠️  ${profile^} is already running.${NC}"
        return 0  # Already running is success
    fi

    # Start via systemd
    if systemctl --user start "$service_name" 2>/dev/null; then
        # Wait and verify
        sleep 2

        if systemctl --user is-active --quiet "$service_name"; then
            # Get the main PID
            local pid
            pid=$(systemctl --user show "$service_name" --property=MainPID --value)
            echo -e "${GREEN}✅ ${profile^} started successfully (PID: ${pid})${NC}"
            return 0
        else
            echo -e "${RED}❌ ${profile^} failed to start. Check logs: journalctl --user -u ${service_name}${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ ${profile^} failed to start.${NC}"
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
            ((success_count++)) || true
        else
            ((fail_count++)) || true
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
