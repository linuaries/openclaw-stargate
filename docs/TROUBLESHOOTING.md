# 🔧 故障排查指南

## 快速诊断流程

```
问题发生
    │
    ├── 网络问题? → 检查Tailscale/节点连通性
    │
    ├── API失败? → 检查API密钥和网络
    │
    ├── GPU问题? → 检查NVIDIA驱动 (仅SGC)
    │
    ├── 本地模型失败? → 检查Ollama (仅SG-2)
    │
    └── 数据丢失? → 从SGC恢复备份
```

---

## 常见问题

### 🔴 问题1: 节点间无法通信

**症状:**
```
SGC Command 无法连接到 Atlantis
报错: "Connection refused" 或 "Timeout"
```

**排查步骤:**

1. **检查Tailscale网络**
```bash
# 检查各节点状态
tailscale status

# 测试连通性
ping 100.64.0.1  # SGC
ping 100.64.0.2  # Atlantis
ping 100.64.0.3  # SG-2

# Tailscale诊断
tailscale ping 100.64.0.2
tailscale netcheck
```

2. **检查OpenClaw服务**
```bash
# 在目标节点上
sudo netstat -tlnp | grep 18789
# 应该显示 0.0.0.0:18789

# 如果不是，修改绑定
openclaw configure --set gateway.bind=0.0.0.0
openclaw gateway restart
```

3. **检查防火墙**
```bash
sudo iptables -L | grep 18789
```

---

### 🔴 问题2: API调用失败

**症状:**
```
调用 GLM-5 或 Kimi 失败
报错: "API key invalid" 或 "timeout"
```

**排查步骤:**

1. **检查API配置**
```bash
openclaw configure --list
cat ~/.openclaw/credentials/zai.yaml
cat ~/.openclaw/credentials/moonshot.yaml
```

2. **测试API连通性**
```bash
# 测试智谱AI
curl -s https://open.bigmodel.cn/api/paas/v4/models \
  -H "Authorization: Bearer $ZAI_API_KEY"

# 测试Moonshot
curl -s https://api.moonshot.cn/v1/models \
  -H "Authorization: Bearer $MOONSHOT_API_KEY"
```

3. **网络问题 (Atlantis)**
```bash
# 测试国际网络连通性
curl -I https://api.moonshot.cn
ping api.moonshot.cn
```

**解决方案:**
- SGC失败 → 自动切换到 Moonshot fallback
- Atlantis失败 → 路由到 SGC 处理

---

### 🔴 问题3: SGC GPU不可用

**症状:**
```
nvidia-smi 报错
PyTorch无法检测CUDA
```

**排查步骤:**

```bash
# 检查NVIDIA驱动
nvidia-smi

# 检查WSL2 GPU支持
ls /usr/lib/wsl/lib/ | grep cuda

# 检查PyTorch GPU
python3 -c "import torch; print(torch.cuda.is_available())"

# 检查CUDA版本
nvcc --version
```

**解决方案:**
```bash
# 重启WSL2 (Windows侧)
wsl --shutdown
# 重新打开WSL2

# 重新安装NVIDIA驱动 (如需要)
```

---

### 🔴 问题4: Atlantis数据丢失

**症状:**
```
重启后配置丢失
MEMORY.md不见了
```

**说明:** 
Atlantis作为云端节点，**不应该存储重要数据**。
所有重要数据应在 **SGC Command (本地)** 保存。

**解决方案:**

1. **从SGC恢复数据**
```bash
# SGC会定期备份到本地
# 从SGC同步回Atlantis
rsync -av sgc-command:/path/to/backup/ ~/.openclaw/memory/
```

2. **重新配置API**
```bash
openclaw configure --section zai
openclaw configure --section moonshot
```

3. **预防措施**
- Atlantis只处理临时任务
- 不保存敏感数据到Atlantis
- 定期从SGC备份

---

### 🔴 问题5: SG-2 Ollama模型加载失败

```bash
# 检查Ollama服务
sudo systemctl status ollama

# 检查内存 (SG-2只有7.6GB)
free -h

# 使用更小的模型
ollama run qwen2.5:1.8b  # 替代3.8B
```

---

### 🔴 问题6: 任务路由错误

**症状:**
```
国际访问任务没有路由到Atlantis
所有任务都在SGC处理
```

**检查路由配置:**

```bash
# 在SGC Command检查
cat ~/.openclaw/fleet.yaml | grep -A 20 "routing:"

# 确保有Atlantis的路由规则
downstream_nodes:
  atlantis-expedition:
    endpoint: http://100.64.0.2:18789
    enabled: true
```

---

## 重启恢复流程

```bash
# 1. 检查网络
tailscale status

# 2. 重启OpenClaw (所有节点)
openclaw gateway restart

# 3. 验证API (SGC和Atlantis)
openclaw test-model zai/glm-5
openclaw test-model moonshot/k2.5

# 4. 验证GPU (SGC)
nvidia-smi

# 5. 验证Ollama (SG-2)
curl http://localhost:11434/api/tags

# 6. 测试节点连通
./scripts/fleet-status.sh
```

---

## 数据备份建议

### SGC Command (本地，主备份)

```bash
# 定期备份到安全位置
crontab -e
# 添加每小时备份
0 * * * * rsync -av ~/.openclaw/memory/ ~/backups/openclaw-memory/
```

### Atlantis (云端，不存敏感数据)

- 只处理临时任务
- 定期同步到SGC
- 可接受数据丢失 (随时可重建)

### SG-2 Recon (本地设备)

- 定期同步到SGC
- 离线数据在本地保存

---

*"Even Atlantis can be rebuilt, as long as SGC stands."* 🛸🌊
