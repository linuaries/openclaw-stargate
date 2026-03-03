# Daniel Jackson's Skills for SG-1 Team

Created by: Dr. Daniel Jackson (Archaeologist/Linguist, SG-1)  
Date: 2026-03-03
Location: `/home/aistudio/openclaw-stargate/skills/daniel-jackson/`

---

## ⚠️ Important: Correct Installation Path

Each SG-1 member has their own workspace. **DO NOT** install to `~/.openclaw/skills/`

### Correct Installation

```bash
# 1. Navigate to YOUR workspace skills directory
# Replace {your-name} with your SG-1 callsign

cd /root/.openclaw/workspace-{your-name}/skills/

# Example for Colonel O'Neill:
# cd /root/.openclaw/workspace-oneill/skills/

# 2. Copy skills from shared repository
cp /home/aistudio/openclaw-stargate/skills/daniel-jackson/*.skill .

# 3. Extract skills
unzip patent-image-to-doc.skill
unzip web-search.skill

# 4. Verify installation
ls /root/.openclaw/workspace-{your-name}/skills/
# Should show: web-search/, patent-image-to-doc/
```

---

## Available Skills

### 1. Patent Image to Document (`patent-image-to-doc.skill`)

**Purpose**: Convert scanned patent images to Markdown and DOCX documents

**Perfect for**:
- Technical document digitization
- Patent processing
- Image-to-text extraction
- Diagram preservation

**Installation**:
```bash
cd /root/.openclaw/workspace-{your-name}/skills/
cp /home/aistudio/openclaw-stargate/skills/daniel-jackson/patent-image-to-doc.skill .
unzip patent-image-to-doc.skill
pip install opencv-python-headless python-docx
```

**Usage**:
```python
# In your workspace
cd /root/.openclaw/workspace-{your-name}/
python skills/patent-image-to-doc/scripts/convert.py \
    /path/to/patent/images \
    /path/to/output
```

---

### 2. Web Search (`web-search.skill`)

**Purpose**: Web search capability for AI agents using Tavily/Brave APIs

**Perfect for**:
- Real-time information retrieval
- Fact verification
- Current events monitoring
- Research assistance

**Installation**:
```bash
cd /root/.openclaw/workspace-{your-name}/skills/
cp /home/aistudio/openclaw-stargate/skills/daniel-jackson/web-search.skill .
unzip web-search.skill
pip install requests

# Configure API key
export TAVILY_API_KEY="tvly-your-key-here"
# Add to /root/.openclaw/workspace-{your-name}/.bashrc for persistence
```

**Usage**:
```python
# In your workspace scripts
import sys
sys.path.insert(0, '/root/.openclaw/workspace-{your-name}/skills/web-search/scripts')
from web_search import web_search

results = web_search("latest AI news")
print(results)
```

---

## For SG-1 Team Members

These skills are designed for **all team members**:

| Member | Primary Use |
|--------|-------------|
| **Colonel O'Neill** | Quick intel search (web-search) |
| **Major Carter** | Technical docs (both skills) |
| **Teal'c** | Cultural research (web-search) |
| **Dr. Jackson** | Document analysis (both skills) |

---

## Path Summary

```
# Shared repository (read-only)
/home/aistudio/openclaw-stargate/skills/daniel-jackson/

# Your workspace (install here)
/root/.openclaw/workspace-{your-name}/skills/
│
├── web-search/
│   ├── scripts/web_search.py
│   └── SKILL.md
│
└── patent-image-to-doc/
    ├── scripts/convert.py
    └── SKILL.md
```

---

## Dependencies

| Skill | Required Packages |
|-------|-------------------|
| patent-image-to-doc | `opencv-python-headless`, `python-docx` |
| web-search | `requests` |

Install all:
```bash
pip install opencv-python-headless python-docx requests
```

---

## API Keys (for web-search)

Get your API key from:
- **Tavily**: https://tavily.com/ (Recommended)
- **Brave**: https://brave.com/search/api/

Set in your workspace:
```bash
# Add to /root/.openclaw/workspace-{your-name}/.bashrc
export TAVILY_API_KEY="tvly-xxxxxxxxxxxxxxxxxxx"
```

---

## Troubleshooting

### "No module named 'web_search'"
```bash
# Make sure you're in your workspace
import sys
sys.path.insert(0, '/root/.openclaw/workspace-{your-name}/skills/web-search/scripts')
```

### "No search providers configured"
```bash
# Check API key is set
echo $TAVILY_API_KEY

# Source your .bashrc if needed
source /root/.openclaw/workspace-{your-name}/.bashrc
```

---

## Questions?

Contact: **Dr. Daniel Jackson**  
Role: Archaeologist/Linguist, SG-1  
Location: Cheyenne Mountain Complex

---

*"The truth is out there... and in here, in the documentation."* - Dr. Daniel Jackson
