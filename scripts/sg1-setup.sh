#!/bin/bash
# 🔧 SG1 Team Setup Script
# Initializes profile directories and configurations for SG1 Team
# 
# Usage:
#   ./sg1-setup.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${PURPLE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           🔧 SG-1 Team Setup                                   ║"
echo "║              Initializing Multi-Gateway Configuration          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# SG1 Team Configuration
declare -A PROFILES=(
    ["oneill"]="18789"
    ["carter"]="18790"
    ["jackson"]="18791"
    ["tealc"]="18792"
)

declare -A WORKSPACES=(
    ["oneill"]="$HOME/.openclaw/workspace"
    ["carter"]="$HOME/.openclaw/workspace-developer"
    ["jackson"]="$HOME/.openclaw/workspace-writer"
    ["tealc"]="$HOME/.openclaw/workspace-security"
)

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../configs"

# Function to setup a profile
setup_profile() {
    local profile="$1"
    local port="${PROFILES[$profile]}"
    local workspace="${WORKSPACES[$profile]}"
    local profile_dir="$HOME/.openclaw-${profile}"
    
    echo -e "${CYAN}Setting up ${profile^}...${NC}"
    
    # Create profile directory
    if [ -d "$profile_dir" ]; then
        echo -e "   ${YELLOW}Profile directory exists: ${profile_dir}${NC}"
    else
        mkdir -p "$profile_dir"
        echo -e "   ${GREEN}Created profile directory: ${profile_dir}${NC}"
    fi
    
    # Create workspace directory
    if [ -d "$workspace" ]; then
        echo -e "   ${YELLOW}Workspace exists: ${workspace}${NC}"
    else
        mkdir -p "$workspace"
        echo -e "   ${GREEN}Created workspace: ${workspace}${NC}"
    fi
    
    # Create log directory
    mkdir -p "${SCRIPT_DIR}/../logs"
    
    # Check for config file
    local config_file="${profile_dir}/openclaw.json"
    if [ -f "$config_file" ]; then
        echo -e "   ${GREEN}Config file exists: ${config_file}${NC}"
    else
        echo -e "   ${YELLOW}Config file not found: ${config_file}${NC}"
        echo -e "   ${YELLOW}Please create the config file with your Discord bot token${NC}"
        echo -e "   ${YELLOW}You can copy from base config and modify:${NC}"
        echo -e "   ${YELLOW}   cp ~/.openclaw/openclaw.json ${config_file}${NC}"
    fi
    
    echo ""
}

# Setup each profile
for profile in oneill carter jackson tealc; do
    setup_profile "$profile"
done

# Make scripts executable
echo -e "${CYAN}Making scripts executable...${NC}"
chmod +x "${SCRIPT_DIR}"/sg1-*.sh
echo -e "${GREEN}✅ Scripts are now executable${NC}"
echo ""

# Summary
echo -e "${PURPLE}────────────────────────────────────────────────────────────────${NC}"
echo -e "${GREEN}✅ SG-1 Team setup complete!${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. Create config files for each profile in ~/.openclaw-<profile>/"
echo -e "     Each config should have a unique Discord bot token"
echo ""
echo -e "  2. Start the team with:"
echo -e "     ${CYAN}./sg1-start.sh${NC}"
echo ""
echo -e "  3. Check status with:"
echo -e "     ${CYAN}./sg1-status.sh${NC}"
echo ""
echo -e "  4. View logs with:"
echo -e "     ${CYAN}./sg1-logs.sh -f${NC}"
echo -e "${PURPLE}────────────────────────────────────────────────────────────────${NC}"
