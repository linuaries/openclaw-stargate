#!/bin/bash
# 📊 SG1 Team Status Check Script
# Displays status of all SG1 team gateways via systemd
#
# Usage:
#   ./sg1-status.sh          # Show status overview
#   ./sg1-status.sh -v       # Verbose mode with details

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
    ["oneill"]="Team Leader"
    ["carter"]="Developer"
    ["jackson"]="Writer"
    ["tealc"]="Security"
)

declare -A EMOJI=(
    ["oneill"]="🎖️"
    ["carter"]="🔬"
    ["jackson"]="📚"
    ["tealc"]="🛡️"
)

# Verbose mode
VERBOSE=false
if [ "${1:-}" = "-v" ] || [ "${1:-}" = "--verbose" ]; then
    VERBOSE=true
fi

# Function to check gateway status
check_gateway() {
    local profile="$1"
    local port="${PROFILES[$profile]}"
    local role="${ROLES[$profile]}"
    local emoji="${EMOJI[$profile]}"
    local service_name="openclaw-gateway-${profile}.service"

    # Check via systemd first
    if systemctl --user is-active --quiet "$service_name" 2>/dev/null; then
        local pid
        pid=$(systemctl --user show "$service_name" --property=MainPID --value)

        echo -e "${GREEN}●${NC} ${emoji} ${profile^}"
        echo -e "   Role: ${role}"
        echo -e "   Port: ${port}"
        echo -e "   PID:  ${pid}"

        if [ "$VERBOSE" = true ]; then
            # Memory usage
            local mem
            mem=$(ps -p "$pid" -o %mem --no-headers 2>/dev/null | tr -d ' ' || echo "N/A")
            echo -e "   Mem:  ${mem}%"

            # CPU usage
            local cpu
            cpu=$(ps -p "$pid" -o %cpu --no-headers 2>/dev/null | tr -d ' ' || echo "N/A")
            echo -e "   CPU:  ${cpu}%"

            # Uptime
            local uptime
            uptime=$(systemctl --user show "$service_name" --property=ActiveEnterTimestamp --value | sed 's/T/ /' | cut -d' ' -f1-2)
            echo -e "   Up:   ${uptime}"
        fi
        return 0
    else
        # Fallback to port check
        local pid
        pid=$(lsof -t -i ":$port" 2>/dev/null || true)

        if [ -n "$pid" ]; then
            echo -e "${YELLOW}●${NC} ${emoji} ${profile^}"
            echo -e "   Role: ${role}"
            echo -e "   Port: ${port}"
            echo -e "   PID:  ${pid}"
            echo -e "   Status: ${YELLOW}Running (not via systemd)${NC}"
            return 0
        else
            echo -e "${RED}○${NC} ${emoji} ${profile^}"
            echo -e "   Role: ${role}"
            echo -e "   Port: ${port}"
            echo -e "   Status: ${RED}OFFLINE${NC}"
            return 1
        fi
    fi
}

# Main display
echo -e "${PURPLE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           📊 SG-1 Team Status Report                           ║"
echo "║              SGC Command - GPU Workstation                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Counters (fixed: removed 'local' keyword)
online=0
offline=0

# Check each gateway
for profile in oneill carter jackson tealc; do
    if check_gateway "$profile"; then
        ((online++)) || true
    else
        ((offline++)) || true
    fi
    echo ""
done

# Summary
echo -e "${PURPLE}────────────────────────────────────────────────────────────────${NC}"
echo -e "Team Status: ${GREEN}${online} online${NC} / ${RED}${offline} offline${NC}"

if [ $offline -eq 0 ]; then
    echo -e "${GREEN}🚀 SG-1 is fully operational!${NC}"
elif [ $online -eq 0 ]; then
    echo -e "${RED}⚠️  SG-1 is offline. Use './sg1-start.sh' to start the team.${NC}"
else
    echo -e "${YELLOW}⚠️  SG-1 is partially operational.${NC}"
fi

echo -e "${PURPLE}────────────────────────────────────────────────────────────────${NC}"
echo -e "Commands:"
echo -e "  ${CYAN}./sg1-start.sh${NC}      - Start all gateways"
echo -e "  ${CYAN}./sg1-stop.sh${NC}       - Stop all gateways"
echo -e "  ${CYAN}./sg1-logs.sh${NC}       - View logs"
echo -e "  ${CYAN}./sg1-restart.sh${NC}    - Restart all gateways"
