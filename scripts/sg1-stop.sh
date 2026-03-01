#!/bin/bash
# 🛑 SG1 Team Gateway Stop Script
# Stops SG1 team gateways via systemd
#
# Usage:
#   ./sg1-stop.sh          # Stop all gateways
#   ./sg1-stop.sh oneill   # Stop specific gateway

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

# Function to stop a single gateway
stop_gateway() {
    local profile="$1"
    local port="${PROFILES[$profile]}"
    local service_name="openclaw-gateway-${profile}.service"

    echo -e "${CYAN}Stopping ${profile^} (port ${port})...${NC}"

    # Check if service exists
    if ! systemctl --user list-unit-files | grep -q "${service_name}"; then
        # Service not installed, check if port is in use
        if lsof -i ":$port" >/dev/null 2>&1; then
            echo -e "${YELLOW}   No systemd service found, but port ${port} is in use.${NC}"
            echo -e "${YELLOW}   Killing process on port ${port}...${NC}"
            local pid=$(lsof -t -i ":$port" 2>/dev/null || true)
            if [ -n "$pid" ]; then
                kill -TERM "$pid" 2>/dev/null || true
                sleep 2
                kill -KILL "$pid" 2>/dev/null || true
            fi
            echo -e "${GREEN}✅ ${profile^} stopped${NC}"
        else
            echo -e "${YELLOW}⚠️  ${profile^} is not running on port ${port}${NC}"
        fi
        return 0
    fi

    # Check if service is active
    if ! systemctl --user is-active --quiet "$service_name"; then
        echo -e "${YELLOW}⚠️  ${profile^} is not running${NC}"
        return 0
    fi

    # Stop via systemd
    if systemctl --user stop "$service_name" 2>/dev/null; then
        echo -e "${GREEN}✅ ${profile^} stopped${NC}"
    else
        echo -e "${RED}❌ Failed to stop ${profile^}${NC}"
        return 1
    fi
}

# Function to stop all gateways
stop_all() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           🛑 SG-1 Team Shutdown Sequence                       ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    # Stop in reverse order (Teal'C first, O'Neill last - leader stays till end)
    for profile in tealc jackson carter oneill; do
        stop_gateway "$profile"
    done

    echo ""
    echo -e "${GREEN}✅ SG-1 Team shutdown complete${NC}"
}

# Main execution
if [ $# -eq 0 ]; then
    stop_all
elif [ $# -eq 1 ]; then
    profile="$1"
    if [[ -v "PROFILES[$profile]" ]]; then
        stop_gateway "$profile"
    else
        echo -e "${RED}❌ Unknown profile: ${profile}${NC}"
        echo -e "Available profiles: ${!PROFILES[*]}"
        exit 1
    fi
else
    echo "Usage: $0 [profile]"
    echo "  No argument: Stop all SG1 gateways"
    echo "  profile: Stop specific gateway (oneill|carter|jackson|tealc)"
    exit 1
fi
