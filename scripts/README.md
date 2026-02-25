# 🛠️ SG-1 Team Management Scripts

Scripts for managing the SG-1 multi-gateway agent team on SGC Command (GPU Workstation).

## 📋 Available Scripts

| Script | Description |
|--------|-------------|
| `sg1-setup.sh` | Initialize profile directories and configurations |
| `sg1-start.sh` | Start all or specific gateways |
| `sg1-stop.sh` | Stop all or specific gateways |
| `sg1-status.sh` | Check status of all gateways |
| `sg1-logs.sh` | View/tail gateway logs |
| `sg1-restart.sh` | Restart all or specific gateways |

## 🚀 Quick Start

```bash
# 1. Initial setup (first time only)
./scripts/sg1-setup.sh

# 2. Start all SG-1 gateways
./scripts/sg1-start.sh

# 3. Check status
./scripts/sg1-status.sh

# 4. View logs in real-time
./scripts/sg1-logs.sh -f
```

## 📖 Usage Details

### sg1-setup.sh

Initializes the profile directories and workspace structure.

```bash
./scripts/sg1-setup.sh
```

This creates:
- `~/.openclaw-oneill/` - O'Neill profile directory
- `~/.openclaw-carter/` - Carter profile directory
- `~/.openclaw-jackson/` - Jackson profile directory
- `~/.openclaw-tealc/` - Teal'C profile directory
- Workspace directories for each agent

### sg1-start.sh

Starts gateways.

```bash
# Start all gateways
./scripts/sg1-start.sh

# Start specific gateway
./scripts/sg1-start.sh oneill
./scripts/sg1-start.sh carter
./scripts/sg1-start.sh jackson
./scripts/sg1-start.sh tealc
```

### sg1-stop.sh

Stops gateways gracefully.

```bash
# Stop all gateways
./scripts/sg1-stop.sh

# Stop specific gateway
./scripts/sg1-stop.sh carter
```

### sg1-status.sh

Shows status of all gateways.

```bash
# Basic status
./scripts/sg1-status.sh

# Verbose mode (includes memory, CPU, uptime)
./scripts/sg1-status.sh -v
```

Output:
```
╔════════════════════════════════════════════════════════════════╗
║           📊 SG-1 Team Status Report                           ║
║              SGC Command - GPU Workstation                     ║
╚════════════════════════════════════════════════════════════════╝

● 🎖️ O'Neill
   Role: Team Leader
   Port: 18789
   PID:  12345

● 🔬 Carter
   Role: Developer
   Port: 18790
   PID:  12346

...
```

### sg1-logs.sh

Views gateway logs.

```bash
# Show recent logs for all gateways
./scripts/sg1-logs.sh

# Show logs for specific gateway
./scripts/sg1-logs.sh oneill

# Follow mode (real-time)
./scripts/sg1-logs.sh -f
./scripts/sg1-logs.sh -f carter
```

### sg1-restart.sh

Restarts gateways.

```bash
# Restart all gateways
./scripts/sg1-restart.sh

# Restart specific gateway
./scripts/sg1-restart.sh carter
```

## 🔧 Configuration

### Gateway Ports

| Agent | Profile | Port |
|-------|---------|------|
| Jack O'Neill | `oneill` | 18789 |
| Samantha Carter | `carter` | 18790 |
| Daniel Jackson | `jackson` | 18791 |
| Teal'C | `tealc` | 18792 |

### Profile Directories

Each agent has its own profile directory:
- `~/.openclaw-oneill/openclaw.json`
- `~/.openclaw-carter/openclaw.json`
- `~/.openclaw-jackson/openclaw.json`
- `~/.openclaw-tealc/openclaw.json`

Each config file should contain:
- Unique Discord bot token
- Agent-specific system prompt
- Appropriate model configuration

### Log Files

Logs are stored in `logs/` directory:
- `logs/gateway-oneill.log`
- `logs/gateway-carter.log`
- `logs/gateway-jackson.log`
- `logs/gateway-tealc.log`

## 🐛 Troubleshooting

### Gateway won't start

1. Check if port is already in use:
   ```bash
   lsof -i :18789
   ```

2. Check log file for errors:
   ```bash
   cat logs/gateway-oneill.log
   ```

3. Verify config file exists:
   ```bash
   ls -la ~/.openclaw-oneill/openclaw.json
   ```

### Gateway appears stuck

1. Check process status:
   ```bash
   ./scripts/sg1-status.sh -v
   ```

2. Restart the gateway:
   ```bash
   ./scripts/sg1-restart.sh oneill
   ```

### Context pollution

If an agent starts behaving outside its role:

1. Review the agent's `SOUL.md` and `USER.md` files
2. Tighten constraints in system prompt
3. Restart the gateway

## 📚 Related Files

- `../configs/sg1-gateways.yaml` - Gateway configuration
- `../agents/` - Agent personality configurations
- `../docs/WORKFLOW.md` - SG-1 workflow documentation
