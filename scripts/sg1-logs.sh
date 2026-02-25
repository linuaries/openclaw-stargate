#!/bin/bash
# 📋 SG1 Team Logs Viewer Script
# View and tail logs for SG1 team gateways
# 
# Usage:
#   ./sg1-logs.sh              # Show all recent logs
#   ./sg1-logs.sh oneill       # Show logs for specific gateway
#   ./sg1-logs.sh -f           # Tail all logs (follow mode)
#   ./sg1-logs.sh -f oneill    # Tail specific gateway logs

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

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/../logs"

# Colors for log prefixes
declare -A LOG_COLORS=(
    ["oneill"]="$GREEN"
    ["carter"]="$BLUE"
    ["jackson"]="$YELLOW"
    ["tealc"]="$PURPLE"
)

# Follow mode
FOLLOW=false
PROFILE=""

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -f|--follow)
            FOLLOW=true
            shift
            ;;
        oneill|carter|jackson|tealc)
            PROFILE="$1"
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Usage: $0 [-f] [profile]"
            echo "  -f: Follow mode (tail -f)"
            echo "  profile: oneill|carter|jackson|tealc"
            exit 1
            ;;
    esac
done

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Function to show logs for a specific profile
show_logs() {
    local profile="$1"
    local log_file="${LOG_DIR}/gateway-${profile}.log"
    local color="${LOG_COLORS[$profile]}"
    
    if [ ! -f "$log_file" ]; then
        echo -e "${YELLOW}No log file for ${profile^}: ${log_file}${NC}"
        return 1
    fi
    
    if [ "$FOLLOW" = true ]; then
        echo -e "${color}[${profile^}]${NC} Following logs... (Ctrl+C to stop)"
        tail -f "$log_file" | while IFS= read -r line; do
            echo -e "${color}[${profile^}]${NC} $line"
        done
    else
        echo -e "${color}═════════════════ ${profile^} Logs ═════════════════${NC}"
        tail -n 50 "$log_file"
        echo ""
    fi
}

# Function to show all logs
show_all_logs() {
    if [ "$FOLLOW" = true ]; then
        echo -e "${CYAN}Following all SG1 logs... (Ctrl+C to stop)${NC}"
        echo ""
        
        # Use tail -f on all log files with colored prefixes
        tail -f "${LOG_DIR}"/gateway-*.log 2>/dev/null | while IFS= read -r line; do
            # Detect which log file the line came from and color accordingly
            if [[ "$line" == *"oneill"* ]]; then
                echo -e "${GREEN}[O'Neill]${NC} $line"
            elif [[ "$line" == *"carter"* ]]; then
                echo -e "${BLUE}[Carter]${NC} $line"
            elif [[ "$line" == *"jackson"* ]]; then
                echo -e "${YELLOW}[Jackson]${NC} $line"
            elif [[ "$line" == *"tealc"* ]]; then
                echo -e "${PURPLE}[Teal'C]${NC} $line"
            else
                echo "$line"
            fi
        done
    else
        echo -e "${PURPLE}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║           📋 SG-1 Team Logs                                    ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        
        for profile in oneill carter jackson tealc; do
            show_logs "$profile"
        done
    fi
}

# Main execution
if [ -n "$PROFILE" ]; then
    show_logs "$PROFILE"
else
    show_all_logs
fi
