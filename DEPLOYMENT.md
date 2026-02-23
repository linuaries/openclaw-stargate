# 🚀 部署指南 (更新版)

## 架构变更说明

- **⭐ SGC Command**: 本地GPU服务器 (ZD-PC) - 指挥中心
- **🌊 Atlantis Expedition**: 腾讯云新加坡 - 国际资源访问
- **🔭 SG-2 Recon**: GPD MicroPC2 - 移动侦察

---

## 前置要求

- 三台设备均已安装 OpenClaw
- 有 sudo 权限
- 网络互通 (推荐Tailscale)
- **API密钥**: SGC和Atlantis需要配置API Provider

---

## 第一步：网络配置 (所有节点)

### 安装 Tailscale

```bash
# 在 SGC Command, Atlantis, SG-2 Recon 都执行

./scripts/setup-tailscale.sh

# 记录各节点的Tailscale IP
# SGC:   100.x.x.1
# Atlantis: 100.x.x.2  
# SG-2:  100.x.x.3
```

### 验证连通性

```bash
# 从SGC Command测试
ping 100.64.0.2  # Atlantis
ping 100.64.0.3  # SG-2
```

---

## 第二步：⭐ SGC Command 部署 (本地GPU服务器)

### 1. 配置API密钥

```bash
# 在 SGC Command (ZD-PC) 执行

# 配置智谱AI
openclaw configure --section zai

# 配置Moonshot (可选)
openclaw configure --section moonshot

# 验证配置
openclaw configure --list
```

### 2. 应用配置

```bash
cp stargate/configs/sgc-command.yaml ~/.openclaw/fleet.yaml

# 编辑配置，填入实际Tailscale IP
nano ~/.openclaw/fleet.yaml
# 修改:
# - tailscale_ip: 100.64.x.1 (SGC自己的IP)
# - downstream_nodes.atlantis-expedition.endpoint: http://100.64.x.2:18789
# - downstream_nodes.sg2-recon.endpoint: http://100.64.x.3:18789

# 重启OpenClaw
openclaw gateway restart
```

### 3. 验证GPU可用

```bash
# 检查NVIDIA驱动
nvidia-smi

# 检查CUDA
nvcc --version

# 测试PyTorch GPU (可选)
python3 -c "import torch; print(torch.cuda.is_available())"
```

---

## 第三步：🌊 Atlantis Expedition 部署 (腾讯云新加坡)

### 1. 配置API密钥

```bash
# 在 Atlantis 执行

# 配置Moonshot (主要)
openclaw configure --section moonshot

# 配置智谱AI (备用)
openclaw configure --section zai

# 验证
openclaw configure --list
```

### 2. 应用配置

```bash
cp stargate/configs/atlantis-expedition.yaml ~/.openclaw/fleet.yaml

# 编辑配置
nano ~/.openclaw/fleet.yaml
# 修改:
# - tailscale_ip: 100.64.x.2 (Atlantis自己的IP)
# - upstream_node.endpoint: http://100.64.x.1:18789 (SGC的IP)

# 重启
openclaw gateway restart
```

### 3. 验证国际访问

```bash
# 测试访问国际网站
curl -I https://openai.com
curl -I https://huggingface.co
```

---

## 第四步：🔭 SG-2 Recon 部署 (GPD MicroPC2)

### 1. 安装本地模型 (用于离线)

```bash
# 在 SG-2 执行
./scripts/install-ollama.sh --profile=recon
```

这将安装:
- Phi-3-Mini (3.8B)
- Qwen2.5-1.8B
- TinyLlama (1.1B)

### 2. 应用配置

```bash
cp stargate/configs/sg2-recon.yaml ~/.openclaw/fleet.yaml

# 配置为移动节点
openclaw configure --set fleet.mode=worker
openclaw configure --set fleet.role=recon

# 重启
openclaw gateway restart
```

---

## 第五步：验证部署

### 检查舰队状态

```bash
# 在 SGC Command 执行
./scripts/fleet-status.sh

# 预期输出:
# ⭐ SGC-Command         🟢 Online (API+GPU)
# 🌊 Atlantis-Expedition 🟢 Online (API)
# 🔭 SG-2-Recon          🟢 Online (API+本地)
```

### 测试任务路由

```bash
# 1. 测试GPU计算 (应在SGC本地)
# 发送: "用GPU生成一张猫的图片"

# 2. 测试代码生成 (应在SGC本地，GLM-5 + 72线程)
# 发送: "用Python写一个快速排序"

# 3. 测试国际资源访问 (应路由到Atlantis)
# 发送: "获取https://openai.com/blog的最新文章"

# 4. 测试离线模式 (应在SG-2本地)
# 在SG-2上断开网络，发送消息
```

---

## 常见问题

### Q: Atlantis API调用失败

```bash
# 检查API配置
openclaw configure --list

# 测试网络
curl -I https://api.moonshot.cn

# 检查到SGC的连通性
ping 100.64.0.1
```

### Q: SGC GPU不可用

```bash
# 检查NVIDIA驱动
nvidia-smi

# 检查WSL2 GPU支持
ls /usr/lib/wsl/lib/

# 重新安装驱动 (如需要)
```

### Q: 节点间无法通信

```bash
# 检查Tailscale
tailscale status

# 检查OpenClaw绑定地址
# 确保是 0.0.0.0 而不是 127.0.0.1
openclaw configure --set gateway.bind=0.0.0.0
openclaw gateway restart
```

---

## 数据备份建议

由于火山云的经验，建议：

```bash
# 在 SGC Command 定期备份
# (因为SGC是本地，最安全)

crontab -e
# 添加:
# 0 */6 * * * cp ~/.openclaw/memory/*.md ~/backups/openclaw/
```

Atlantis作为云端节点：
- 不存储敏感数据
- 定期同步到SGC
- 可随时重建

---

*"SGC to Atlantis, expedition ready."* 🛸🌊
