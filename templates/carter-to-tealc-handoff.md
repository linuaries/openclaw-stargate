# Carter → Teal'C Deployment Handoff Template
# Usage: Copy this file, fill in all sections, rename to task-name.handoff.md
# Status: 🚧 WIP → ⏳ REVIEW → ✅ READY → 🚀 EXEC → 📊 DONE

---

## 📋 Task Overview

**Task ID:** `TASK-YYYY-MM-DD-XXX`  
**Task Name:** `[Brief descriptive name]`  
**Created By:** Carter  
**Created At:** `YYYY-MM-DD HH:MM:SS`  
**Priority:** `[P0 Critical / P1 High / P2 Normal / P3 Low]`  
**Estimated Duration:** `[X minutes/hours]`

---

## 🎯 Objective

**What needs to be done:**
```
[Clear, concise description of the goal]
```

**Success Criteria:**
- [ ] Criterion 1: `[Specific, measurable outcome]`
- [ ] Criterion 2: `[Specific, measurable outcome]`
- [ ] Criterion 3: `[Specific, measurable outcome]`

---

## 📦 Deliverables

### 1. Code/Scripts
| File | Purpose | Location |
|------|---------|----------|
| `script.py` | Main deployment script | `./deploy/script.py` |
| `config.yaml` | Configuration template | `./deploy/config.yaml` |
| `requirements.txt` | Python dependencies | `./deploy/requirements.txt` |

### 2. Documentation
| File | Description | Status |
|------|-------------|--------|
| `README.md` | Quick start guide | ✅ Included |
| `TESTING.md` | Verification steps | ✅ Included |
| `ROLLBACK.md` | Failure recovery | ✅ Included |

---

## 🔧 Environment Setup

### Prerequisites
```bash
# Required system packages
- [ ] Docker version X.X+
- [ ] Python 3.10+
- [ ] GPU drivers (if applicable)
```

### Environment Variables
Copy `.env.example` to `.env` and configure:

```bash
# Required
DATABASE_URL=           # Database connection string
API_KEY=               # Service API key
GPU_DEVICE=0           # GPU device index

# Optional
LOG_LEVEL=INFO         # DEBUG, INFO, WARNING, ERROR
PORT=8080             # Service port
```

### Installation Steps
```bash
# 1. Setup virtual environment
python -m venv venv
source venv/bin/activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Verify installation
python -c "import main; print('OK')"
```

---

## 🚀 Deployment Instructions

### Step-by-Step Runbook

```bash
# Step 1: Pre-deployment checks
./scripts/pre-check.sh
# Expected: All checks pass

# Step 2: Deploy
cd deploy && python deploy.py --env=production
# Expected: Deployment completes in ~2 minutes

# Step 3: Health check
curl http://localhost:8080/health
# Expected: {"status": "healthy", "version": "1.2.3"}

# Step 4: Verify functionality
./scripts/smoke-test.sh
# Expected: All tests pass
```

### Verification Commands
```bash
# Check service status
systemctl status my-service

# View logs
tail -f /var/log/my-service/app.log

# Check resource usage
nvidia-smi  # GPU
htop        # CPU/Memory
```

---

## 🧪 Testing & Validation

### Automated Tests
```bash
# Run test suite
pytest tests/ -v

# Expected output:
# ================= 12 passed in 3.45s =================
```

### Manual Verification Checklist
- [ ] Service responds to health check
- [ ] API endpoints return expected data
- [ ] No errors in logs (first 5 minutes)
- [ ] Resource usage within limits (<80% CPU, <4GB RAM)
- [ ] Database connections stable

---

## ⚠️ Known Issues & Limitations

| Issue | Impact | Workaround |
|-------|--------|------------|
| `[Brief description]` | `[High/Med/Low]` | `[How to handle]` |
| Cold start takes 30s | Medium | Pre-warm endpoint before traffic |

---

## 🔄 Rollback Procedure

### If Deployment Fails:

```bash
# Step 1: Stop new deployment
docker-compose down

# Step 2: Restore previous version
./scripts/rollback.sh v1.2.2

# Step 3: Verify rollback
curl http://localhost:8080/version
# Expected: {"version": "1.2.2"}

# Step 4: Notify Carter
# Send message with failure details
```

### Emergency Contacts
- **Carter (Code Issues):** @carter-gateway
- **O'Neill (Escalation):** @oneill-gateway
- **On-Call:** `[contact info]`

---

## 📊 Expected Output

### Success Indicators
```
[Example of what successful output looks like]
```

### Metrics to Capture
- Deployment duration: `[expected time]`
- Memory usage: `[expected MB]`
- Response time: `[expected ms]`
- Error rate: `< 0.1%`

---

## 📝 Teal'C Execution Report (To be filled by Teal'C)

### Execution Summary
**Started At:** `___________`  
**Completed At:** `___________`  
**Status:** `[ ] SUCCESS  [ ] PARTIAL  [ ] FAILURE`

### Actual Results
```
[Paste actual output here]
```

### Verification Results
- [ ] All success criteria met
- [ ] No unexpected errors
- [ ] Performance within expected range

### Issues Encountered
| Severity | Description | Resolution |
|----------|-------------|------------|
| `[High/Med/Low]` | `[What happened]` | `[How resolved]` |

### Recommendations for Carter
```
[Teal'C: Suggest improvements based on execution experience]
```

---

## ✅ Handoff Checklist

### Carter (Before Handoff):
- [ ] All code committed and pushed
- [ ] README.md is clear and complete
- [ ] Tested on development environment
- [ ] Rollback procedure documented and tested
- [ ] All known issues documented
- [ ] This template completely filled

### Teal'C (After Execution):
- [ ] Execution report completed
- [ ] All logs captured and attached
- [ ] Metrics recorded
- [ ] Feedback provided to Carter
- [ ] Status updated in tracking system

---

**Status:** 🚧 WIP → ⏳ REVIEW → **🚀 READY FOR TEAL'C** → 🔄 EXEC → ✅ DONE  
**Last Updated:** `YYYY-MM-DD HH:MM:SS by [Name]`
