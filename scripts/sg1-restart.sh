#!/bin/bash
# 🔄 SG1 Team Restart Script
# Restarts SG1 team gateways
# 
# Usage:
#   ./sg1-restart.sh          # Restart all gateways
#   ./sg1-restart.sh oneill   # Restart specific gateway

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

# SG1 Team Configuration
declare -A PROFILES=(
    ["oneill"]="18789"
    ["carter"]="18799"
    ["jackson"]="18809"
    ["tealc"]="18819"
)

# Function to restart a single gateway
restart_gateway() {
    local profile="$1"
    
    echo -e "${CYAN}Restarting ${profile^}...${NC}"
    
    # Stop
    "$SCRIPT_DIR/sg1-stop.sh" "$profile" 2>/dev/null || true
    
    # Brief pause
    sleep 2
    
    # Start
    "$SCRIPT_DIR/sg1-start.sh" "$profile"
    
    echo -e "${GREEN}✅ ${profile^} restarted${NC}"
}

# Function to restart all gateways
restart_all() {
    echo -e "${CYAN}🔄 Restarting SG-1 Team...${NC}"
    echo ""
    
    # Stop all first
    "$SCRIPT_DIR/sg1-stop.sh" 2>/dev/null || true
    
    echo ""
    echo "Waiting 3 seconds..."
    sleep 3
    echo ""
    
    # Start all
    "$SCRIPT_DIR/sg1-start.sh"
}

# Main execution
if [ $# -eq 0 ]; then
    restart_all
elif [ $# -eq 1 ]; then
    profile="$1"
    if [[ -v "PROFILES[$profile]" ]]; then
        restart_gateway "$profile"
    else
        echo -e "${RED}❌ Unknown profile: ${profile}${NC}"
        echo -e "Available profiles: ${!PROFILES[*]}"
        exit 1
    fi
else
    echo "Usage: $0 [profile]"
    echo "  No argument: Restart all SG1 gateways"
    echo "  profile: Restart specific gateway (oneill|carter|jackson|tealc)"
    exit 1
fi

# Source the stop script for RED color
RED='\033[0;31m'
