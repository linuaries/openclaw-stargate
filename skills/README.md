# SG-1 Team Skills Repository

Shared skills library for Stargate SG-1 team members.

## Repository Structure

```
/home/aistudio/openclaw-stargate/skills/           # Shared repository
├── README.md                                      # This file
└── daniel-jackson/                                # Dr. Daniel Jackson's skills
    ├── README.md
    ├── patent-image-to-doc.skill
    └── web-search.skill
```

## Individual Member Structure

Each SG-1 member has their own workspace:

```
/root/.openclaw/workspace-{member-name}/           # Member workspace
├── skills/                                        # Member's skills directory
│   └── [extracted .skill files here]
├── SOUL.md                                        # Member's persona
├── AGENTS.md                                      # Member's agent config
└── ...
```

## Quick Start

### Installing a Skill (Correct Path)

```bash
# 1. Navigate to your workspace skills directory
cd /root/.openclaw/workspace-{your-name}/skills/

# 2. Copy skill from shared repository
cp /home/aistudio/openclaw-stargate/skills/daniel-jackson/web-search.skill .

# 3. Extract skill
cd /root/.openclaw/workspace-{your-name}/skills/
unzip web-search.skill

# 4. Install dependencies
pip install requests opencv-python-headless python-docx

# 5. Configure API key (for web-search)
export TAVILY_API_KEY="your-key"
# or add to your ~/.bashrc
```

### Example: For Colonel O'Neill

```bash
# Jack's workspace
cd /root/.openclaw/workspace-oneill/skills/

# Copy skill
cp /home/aistudio/openclaw-stargate/skills/daniel-jackson/web-search.skill .

# Extract
unzip web-search.skill

# Verify
ls /root/.openclaw/workspace-oneill/skills/web-search/
```

### Example: For Major Carter

```bash
# Sam's workspace
cd /root/.openclaw/workspace-carter/skills/

# Copy both skills
cp /home/aistudio/openclaw-stargate/skills/daniel-jackson/*.skill .

# Extract all
unzip '*.skill'
```

## Creating Your Own Skills

1. **Create your workspace** (if not exists):
   ```bash
   mkdir -p /root/.openclaw/workspace-{your-name}/skills/
   ```

2. **Develop skill** in your workspace:
   ```bash
   cd /root/.openclaw/workspace-{your-name}/skills/
   # Create skill folder and files
   ```

3. **Package skill**:
   ```bash
   cd /root/.openclaw/workspace-{your-name}/skills/
   zip -r my-skill.skill my-skill/
   ```

4. **Copy to shared repository**:
   ```bash
   cp my-skill.skill /home/aistudio/openclaw-stargate/skills/{your-name}/
   ```

5. **Update shared README**

## Available Skills by Member

### Dr. Daniel Jackson

| Skill | Description | Size |
|-------|-------------|------|
| `patent-image-to-doc.skill` | Convert patent images to Markdown/DOCX | 7.1 KB |
| `web-search.skill` | Web search with MCP protocol | 14 KB |

**Role**: Archaeologist/Linguist  
**Expertise**: Document analysis, translation, research

---

## Path Reference

| Location | Path |
|----------|------|
| **Shared Repository** | `/home/aistudio/openclaw-stargate/skills/` |
| **Daniel's Skills** | `/home/aistudio/openclaw-stargate/skills/daniel-jackson/` |
| **Daniel's Workspace** | `/root/.openclaw/workspace-jackson/` |
| **Member Workspaces** | `/root/.openclaw/workspace-{name}/` |
| **Member Skills** | `/root/.openclaw/workspace-{name}/skills/` |

---

## Team Members

| Member | Workspace | Skills Contributed |
|--------|-----------|-------------------|
| Dr. Daniel Jackson | `/workspace-jackson/` | 2 skills |
| [Colonel O'Neill] | `/workspace-oneill/` | - |
| [Major Carter] | `/workspace-carter/` | - |
| [Teal'c] | `/workspace-tealc/` | - |

---

## Best Practices

1. **Always extract skills to your workspace skills folder**, NOT to ~/.openclaw/skills/
2. **Use your name in the workspace path**: `workspace-jackson`, `workspace-oneill`, etc.
3. **Share packaged .skill files** in `/home/aistudio/openclaw-stargate/skills/{your-name}/`
4. **Test skills** in your workspace before sharing
5. **Update README** when adding new skills

---

*"We do this together. As a team."* - Colonel Jack O'Neill
