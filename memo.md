  ┌────────────┬───────┬───────┬───────────┐                                                  
  │   Agent    │ Port  │  PID  │  Status   │   
  ├────────────┼───────┼───────┼───────────┤                                                  
  │ 🎖️  O'Neill │ 18789 │ 42328 │ ✅ Online │                                                  
  ├────────────┼───────┼───────┼───────────┤
  │ 🔬 Carter  │ 18799 │ 42465 │ ✅ Online │
  ├────────────┼───────┼───────┼───────────┤
  │ 📚 Jackson │ 18809 │ 42604 │ ✅ Online │
  ├────────────┼───────┼───────┼───────────┤
  │ 🛡️  Teal'C  │ 18819 │ 42743 │ ✅ Online │
  └────────────┴───────┴───────┴───────────┘

openclaw gateway start --profile main --port 18789
# Oneill
openclaw --profile oneill gateway start --port 18789
openclaw --profile oneill onboard --install-daemon
# Carter
openclaw --profile carter gateway start --port 18799
openclaw --profile carter onboard --install-daemon

# Daniel Jackson
openclaw --profile jackson gateway start --port 18809
openclaw --profile jackson onboard --install-daemon

# Teal'c
openclaw --profile tealc gateway start --port 18819
openclaw --profile tealc onboard --install-daemon

---

## Mission Log: 2026-02-26

### Azure OpenAI Configuration Documentation
**Completed by:** Maj. Samantha Carter

**Deliverables:**
1. `/docs/AZURE-OPENAI.md` — Comprehensive configuration guide
   - Prerequisites and Azure resource setup
   - Three configuration options (env vars, custom provider, LiteLLM)
   - Authentication methods (API key, Azure AD)
   - Best practices for fallback, HA, rate limits, security
   - Model selection guide
   - Troubleshooting

2. `/configs/azure-openai-provider.json5` — Ready-to-use config template
   - Environment variables
   - Custom provider configuration
   - Fallback chain setup
   - Model aliases

3. `/scripts/setup-azure-openai.sh` — Interactive setup script
   - Prompts for Azure details
   - Updates ~/.openclaw/.env
   - Tests connection
   - Provides next steps

**Usage:**
```bash
# Run setup script
./scripts/setup-azure-openai.sh

# Or manually add to config:
# See docs/AZURE-OPENAI.md for details
```

**Status:** ✅ Complete — Ready for review by Teal'c (security) and Daniel (documentation)


after bash run "/home/aistudio/openclaw-stargate/.venv/bin/python /home/aistudio/openclaw-stargate/scripts/test_connection_feishu.py", got this error: '''File "/home/aistudio/openclaw-stargate/scripts/test_connection_feishu.py", line 19
    .register_p2_im_message_receive_v1(do_p2_im_message_receive_v1) \
IndentationError: unexpected indent ''', please help to fix