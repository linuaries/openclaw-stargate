#!/bin/bash
# 🛑 SG1 Team Gateway Stop Script
# Stops SG1 team gateways gracefully
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
    ["carter"]="18790"
    ["jackson"]="18791"
    ["tealc"]="18792"
)

# Function to stop a single gateway
stop_gateway() {
    local profile="$1"
    local port="${PROFILES[$profile]}"
    
    echo -e "${CYAN}Stopping ${profile^} (port ${port})...${NC}"
    
    # Find process by port
    local pid=$(lsof -t -i ":$port" 2>/dev/null || true)
    
    if [ -z "$pid" ]; then
        echo -e "${YELLOW}⚠️  ${profile^} is not running on port ${port}${NC}"
        return 0
    fi
    
    # Try graceful shutdown first
    kill -TERM "$pid" 2>/dev/null || true
    
    # Wait up to 5 seconds for graceful shutdown
    local count=0
    while kill -0 "$pid" 2>/dev/null && [ $count -lt 5 ]; do
        sleep 1
        ((count++))
        echo -e "   Waiting for ${profile^} to stop... (${count}s)"
    done
    
    # Force kill if still running
    if kill -0 "$pid" 2>/dev/null; then
        echo -e "${YELLOW}   Force killing ${profile^}...${NC}"
        kill -KILL "$pid" 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✅ ${profile^} stopped${NC}"
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
