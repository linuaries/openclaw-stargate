# Teal'C Execution Report Template
# Usage: Fill this after completing a Carter-assigned task
# File naming: execution-report-TASK-ID.md

---

## 📋 Execution Summary

**Task ID:** `TASK-YYYY-MM-DD-XXX`  
**Task Name:** `[Task name from handoff]`  
**Assigned By:** Carter  
**Executed By:** Teal'C  
**Execution Start:** `YYYY-MM-DD HH:MM:SS`  
**Execution End:** `YYYY-MM-DD HH:MM:SS`  
**Duration:** `X minutes Y seconds`

### Final Status
**[ ] ✅ SUCCESS** - All objectives completed  
**[ ] ⚠️ PARTIAL** - Some objectives completed, issues encountered  
**[ ] ❌ FAILURE** - Unable to complete, escalation required

---

## 🎯 Objectives vs Results

| Objective | Target | Actual | Status |
|-----------|--------|--------|--------|
| `[From handoff]` | `[Expected]` | `[Measured]` | ✅/⚠️/❌ |

---

## 📊 System Metrics

### Resource Usage (Peak)
```
CPU:     XX%  / Target: <YY%
Memory:  X.X GB / Target: <Y.Y GB
GPU:     XX% utilization
Disk:    X.X GB written
Network: X.X MB transferred
```

### Service Health
```bash
# Health check output
curl http://localhost:8080/health
{
  "status": "healthy",
  "timestamp": "2026-03-07T13:25:00Z",
  "version": "1.2.3"
}
```

---

## 📝 Execution Log

### Phase 1: Environment Setup
```bash
[XX:XX:XX] Activating virtual environment...
[XX:XX:XX] Installing dependencies... OK (12s)
[XX:XX:XX] Loading environment variables... OK
[XX:XX:XX] Pre-check script passed
```

### Phase 2: Deployment
```bash
[XX:XX:XX] Starting deployment...
[XX:XX:XX] Building Docker image... OK (45s)
[XX:XX:XX] Starting containers... OK
[XX:XX:XX] Running migrations... OK (8s)
```

### Phase 3: Verification
```bash
[XX:XX:XX] Running smoke tests...
[XX:XX:XX] Test 1/5: API health... PASS
[XX:XX:XX] Test 2/5: Database connection... PASS
[XX:XX:XX] Test 3/5: GPU availability... PASS
[XX:XX:XX] Test 4/5: Response time <100ms... PASS
[XX:XX:XX] Test 5/5: Error rate <0.1%... PASS
```

---

## ⚠️ Issues Encountered

### Issue #1: `[Brief title]`
- **Severity:** `[Critical/Major/Minor]`
- **Time:** `XX:XX:XX`
- **Description:** `[What happened]`
- **Root Cause:** `[Why it happened]`
- **Resolution:** `[How it was fixed]`
- **Prevention:** `[How to avoid in future]`

### Issue #2: `[If applicable]`
...

---

## 🔍 Verification Evidence

### Test Results
```
[Output from test commands]
```

### Log Snippets
```
[Relevant log entries showing success/errors]
```

### Screenshots/Artifacts
- `[Attach or link to relevant files]`

---

## 💡 Feedback for Carter

### What Worked Well
- `[Positive observations about the handoff]`

### Suggested Improvements
| Area | Suggestion | Priority |
|------|------------|----------|
| Documentation | `[Specific improvement]` | `[High/Med/Low]` |
| Script | `[Specific improvement]` | `[High/Med/Low]` |
| Process | `[Specific improvement]` | `[High/Med/Low]` |

### Unexpected Findings
- `[Anything discovered during execution worth noting]`

---

## 📎 Attachments

- [ ] Full execution logs: `[path/to/logs]`
- [ ] System metrics: `[path/to/metrics.json]`
- [ ] Test output: `[path/to/test-results]`
- [ ] Screenshots: `[if applicable]`

---

## ✅ Sign-off

**Teal'C Confirmation:**  
I confirm that:
- [ ] All execution steps were followed as documented
- [ ] All results are accurate and complete
- [ ] All artifacts have been preserved
- [ ] Carter has been notified of completion

**Next Actions:**
- `[Any follow-up tasks]`

**Report Submitted:** `YYYY-MM-DD HH:MM:SS`  
**By:** Teal'C (sg1-tealc)

---

## 📨 Handoff Back to Carter

Status update message:
```
@Carter - Task [TASK-ID] completed.

Status: ✅ SUCCESS / ⚠️ PARTIAL / ❌ FAILURE
Duration: X minutes
Issues: [0/1/2] - [Brief summary if any]

Full report: [Link to this file]
Logs: [Link to logs]

[Teal'C's recommendations summary]
```
