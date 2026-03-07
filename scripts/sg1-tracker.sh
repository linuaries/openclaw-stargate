#!/bin/bash
# SG-1 Team Status Tracker
# Monitors Carter→Teal'C handoffs and overall team status
# Usage: ./sg1-tracker.sh [status|handoffs|report|help]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TRACKING_DIR="$PROJECT_DIR/tracking"
LOGS_DIR="$PROJECT_DIR/logs"

# Ensure tracking directory exists
mkdir -p "$TRACKING_DIR"

# Port configuration (from sg1-gateways.yaml)
ONEILL_PORT=18789
CARTER_PORT=18799
JACKSON_PORT=18809
TEALC_PORT=18819
WOOLSEY_PORT=18829

# ============================================
# Helper Functions
# ============================================

check_gateway() {
    local port=$1
    local name=$2
    local emoji=$3
    
    if nc -z localhost "$port" 2>/dev/null; then
        local pid
        pid=$(lsof -ti :"$port" 2>/dev/null || echo "?")
        echo -e "${GREEN}✅${NC} $emoji $name (port:$port, pid:$pid)"
        return 0
    else
        echo -e "${RED}❌${NC} $emoji $name (port:$port) - OFFLINE"
        return 1
    fi
}

format_duration() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    
    if [ $hours -gt 0 ]; then
        printf "%dh %dm %ds" $hours $minutes $secs
    elif [ $minutes -gt 0 ]; then
        printf "%dm %ds" $minutes $secs
    else
        printf "%ds" $secs
    fi
}

# ============================================
# Commands
# ============================================

cmd_status() {
    echo "========================================"
    echo "🚀 SG-1 Team Gateway Status"
    echo "========================================"
    echo ""
    
    local online=0
    local total=5
    
    check_gateway $ONEILL_PORT "O'Neill" "🎖️" && ((online++))
    check_gateway $CARTER_PORT "Carter" "🔬" && ((online++))
    check_gateway $JACKSON_PORT "Jackson" "📚" && ((online++))
    check_gateway $TEALC_PORT "Teal'C" "🛡️" && ((online++))
    check_gateway $WOOLSEY_PORT "Woolsey" "📋" && ((online++))
    
    echo ""
    echo "========================================"
    echo -e "Online: ${GREEN}$online${NC}/$total gateways"
    
    if [ $online -lt $total ]; then
        echo -e "${YELLOW}⚠️  Some gateways are offline${NC}"
        echo "Run: ./sg1-start.sh to start all"
    fi
    echo "========================================"
}

cmd_handoffs() {
    echo "========================================"
    echo "🔄 Carter → Teal'C Handoff Status"
    echo "========================================"
    echo ""
    
    local handoff_dir="$TRACKING_DIR/handoffs"
    mkdir -p "$handoff_dir"
    
    # Scan for handoff files
    local pending=0
    local in_progress=0
    local completed=0
    
    echo -e "${BLUE}📋 Pending Handoffs (from Carter):${NC}"
    echo "----------------------------------------"
    
    for file in "$handoff_dir"/*.handoff.md; do
        if [ -f "$file" ]; then
            local task_id
            task_id=$(basename "$file" .handoff.md)
            local status
            status=$(grep -o "Status:.*" "$file" 2>/dev/null | head -1 || echo "Status: UNKNOWN")
            
            case "$status" in
                *WIP*)
                    echo -e "  🚧 $task_id - Work in Progress"
                    ((pending++))
                    ;;
                *READY*)
                    echo -e "  ${GREEN}🚀${NC} $task_id - ${GREEN}READY FOR TEAL'C${NC}"
                    ((pending++))
                    ;;
                *EXEC*)
                    echo -e "  ${YELLOW}🔄${NC} $task_id - ${YELLOW}In Progress${NC}"
                    ((in_progress++))
                    ;;
                *DONE*)
                    ((completed++))
                    ;;
            esac
        fi
    done
    
    if [ $pending -eq 0 ] && [ $in_progress -eq 0 ]; then
        echo -e "  ${YELLOW}No pending handoffs${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}🔄 In Progress:${NC}"
    echo "----------------------------------------"
    
    for file in "$handoff_dir"/*.handoff.md; do
        if [ -f "$file" ]; then
            local task_id
            task_id=$(basename "$file" .handoff.md)
            if grep -q "Status:.*EXEC" "$file" 2>/dev/null; then
                echo -e "  🔄 $task_id"
            fi
        fi
    done
    
    echo ""
    echo "========================================"
    echo "Summary: $pending pending | $in_progress active | $completed completed"
    echo "========================================"
}

cmd_report() {
    echo "========================================"
    echo "📊 SG-1 Team Activity Report"
    echo "========================================"
    echo ""
    
    local report_file="$TRACKING_DIR/daily-report-$(date +%Y-%m-%d).md"
    
    # Collect data
    local total_tasks=0
    local successful=0
    local failed=0
    local avg_duration=0
    
    # Count execution reports
    for file in "$TRACKING_DIR"/execution-report-*.md; do
        if [ -f "$file" ]; then
            ((total_tasks++))
            if grep -q "✅ SUCCESS" "$file" 2>/dev/null; then
                ((successful++))
            elif grep -q "❌ FAILURE" "$file" 2>/dev/null; then
                ((failed++))
            fi
        fi
    done
    
    # Generate report
    cat > "$report_file" << EOF
# SG-1 Daily Activity Report

**Date:** $(date +%Y-%m-%d)  
**Generated:** $(date '+%Y-%m-%d %H:%M:%S')

## 📈 Summary Statistics

| Metric | Value |
|--------|-------|
| Total Tasks Executed | $total_tasks |
| Successful | $successful |
| Failed | $failed |
| Success Rate | $(if [ $total_tasks -gt 0 ]; then echo $(( successful * 100 / total_tasks ))%; else echo "N/A"; fi) |

## 🚀 Gateway Status

$(cmd_status 2>&1 | grep -E "^[✅❌]")

## 🔄 Handoff Activity

$(cmd_handoffs 2>&1 | grep -E "^[[:space:]]+[🚧🚀🔄]" || echo "No active handoffs")

## 📋 Recent Executions

EOF

    # Add recent execution summaries
    for file in $(ls -t "$TRACKING_DIR"/execution-report-*.md 2>/dev/null | head -5); do
        if [ -f "$file" ]; then
            local task_id
            task_id=$(basename "$file" .md | sed 's/execution-report-//')
            local status
            status=$(grep "^\*\*\[ \]" "$file" 2>/dev/null | grep -o "✅.*\|⚠️.*\|❌.*" || echo "Unknown")
            echo "- **$task_id**: $status" >> "$report_file"
        fi
    done
    
    cat >> "$report_file" << EOF

## 🎯 Action Items

- [ ] Review failed tasks
- [ ] Update documentation based on Teal'C feedback
- [ ] Check resource utilization trends

---
*Report saved to: $report_file*
EOF

    echo "Report generated: $report_file"
    echo ""
    cat "$report_file"
}

cmd_create_handoff() {
    local task_name=$1
    if [ -z "$task_name" ]; then
        echo -e "${RED}Error: Task name required${NC}"
        echo "Usage: $0 create-handoff <task-name>"
        exit 1
    fi
    
    local task_id="TASK-$(date +%Y%m%d)-$(echo "$task_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
    local handoff_file="$TRACKING_DIR/handoffs/$task_id.handoff.md"
    
    mkdir -p "$TRACKING_DIR/handoffs"
    cp "$PROJECT_DIR/templates/carter-to-tealc-handoff.md" "$handoff_file"
    
    # Update placeholders
    sed -i "s/TASK-YYYY-MM-DD-XXX/$task_id/g" "$handoff_file"
    sed -i "s/\[Brief descriptive name\]/$task_name/g" "$handoff_file"
    sed -i "s/YYYY-MM-DD HH:MM:SS/$(date '+%Y-%m-%d %H:%M:%S')/g" "$handoff_file"
    
    echo -e "${GREEN}✅ Created handoff template:${NC} $handoff_file"
    echo ""
    echo "Next steps:"
    echo "1. Edit the file to fill in all sections"
    echo "2. Update status to 🚀 READY FOR TEAL'C when complete"
    echo "3. Teal'C will be notified automatically"
}

cmd_complete() {
    local task_id=$1
    local status=$2
    
    if [ -z "$task_id" ] || [ -z "$status" ]; then
        echo -e "${RED}Error: Task ID and status required${NC}"
        echo "Usage: $0 complete <task-id> [success|partial|failure]"
        exit 1
    fi
    
    local handoff_file="$TRACKING_DIR/handoffs/$task_id.handoff.md"
    
    if [ ! -f "$handoff_file" ]; then
        echo -e "${RED}Error: Handoff file not found: $handoff_file${NC}"
        exit 1
    fi
    
    # Update status
    case "$status" in
        success)
            sed -i 's/🚀 READY FOR TEAL'C/✅ DONE/g' "$handoff_file"
            echo -e "${GREEN}✅ Marked $task_id as completed${NC}"
            ;;
        partial)
            sed -i 's/🚀 READY FOR TEAL'C/⚠️ PARTIAL/g' "$handoff_file"
            echo -e "${YELLOW}⚠️ Marked $task_id as partially complete${NC}"
            ;;
        failure)
            sed -i 's/🚀 READY FOR TEAL'C/❌ FAILED/g' "$handoff_file"
            echo -e "${RED}❌ Marked $task_id as failed${NC}"
            ;;
        *)
            echo -e "${RED}Error: Invalid status. Use: success, partial, or failure${NC}"
            exit 1
            ;;
    esac
}

cmd_help() {
    cat << EOF
SG-1 Team Status Tracker

USAGE:
    $0 <command> [options]

COMMANDS:
    status              Show gateway status for all SG-1 members
    handoffs            List Carter→Teal'C handoff queue
    report              Generate daily activity report
    create-handoff <name>  Create new handoff template for Carter
    complete <id> <status>  Mark handoff as complete (success|partial|failure)
    help                Show this help message

EXAMPLES:
    $0 status                    # Check all gateways
    $0 handoffs                  # View pending handoffs
    $0 create-handoff "Deploy API v2"  # Create new handoff
    $0 complete TASK-20260307-001 success  # Mark task complete

FILES:
    tracking/handoffs/       - Handoff documents
    tracking/daily-report-*.md - Generated reports
    templates/               - Handoff templates

EOF
}

# ============================================
# Main
# ============================================

case "${1:-status}" in
    status)
        cmd_status
        ;;
    handoffs)
        cmd_handoffs
        ;;
    report)
        cmd_report
        ;;
    create-handoff)
        cmd_create_handoff "${2:-}"
        ;;
    complete)
        cmd_complete "${2:-}" "${3:-}"
        ;;
    help|--help|-h)
        cmd_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        cmd_help
        exit 1
        ;;
esac
