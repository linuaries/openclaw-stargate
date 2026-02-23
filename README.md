# 🛸 Stargate SGC 远征舰队

基于《星际之门》组织架构的分布式 OpenClaw 多 Agent 系统。

---

## 🗺️ 架构概览 (更新版)

```
                            🌐 Internet
                               │
          ┌────────────────────┼────────────────────┐
          │                    │                    │
    ┌─────▼──────┐    ┌───────▼────────┐    ┌──────▼──────┐
    │   ⭐SGC     │    │  🌊 Atlantis   │    │   🔭SG-2    │
    │  Command   │◄──►│  Expedition    │    │   Recon     │
    │ 本地GPU    │ VPN │  腾讯云新加坡   │    │ GPD Micro   │
    │ Xeon+3060  │     │  2vCPU/2GB     │    │ N250+7.6G   │
    └─────┬──────┘    └────────────────┘    └──────┬──────┘
          │                                         │
    ┌─────▼──────┐                            ┌─────▼──────┐
    │QQ/Discord  │                            │ 离线模式   │
    └────────────┘                            └────────────┘
```

---

## 🎭 舰队成员

| 代号 | 主机名 | 位置 | 硬件 | 角色 | Provider |
|------|--------|------|------|------|----------|
| **⭐SGC Command** | ZD-PC | 本地WSL2工作站 | Xeon 72T + RTX 3060 12GB + 62GB | **指挥中心** + GPU计算 | zai/glm-5, moonshot/k2.5 |
| **🌊Atlantis Expedition** | VM-0-2-opencloudos | 腾讯云新加坡 | 2vCPU/2GB | **国际资源访问节点** | kimi-coding/k2.5 |
| **🔭SG-2 Recon** | DESKTOP-1156LM3 | GPD MicroPC2 | N250 4C/4T + 7.6GB | 移动侦察 | minimax-cn/MiniMax-M2.5 |

---

## 🎯 角色定义

### ⭐ SGC Command（本地GPU服务器）
- **位置**: 本地（最安全）
- **职责**: 
  - 任务路由中心
  - 全局记忆主库（MEMORY.md）
  - **GPU计算**: 图像处理、声音处理、本地Embedding
  - 外部接口（QQ/Discord）
- **优势**: 数据不会丢失，有完整备份

### 🌊 Atlantis Expedition（腾讯云新加坡）
- **位置**: 腾讯云新加坡
- **职责**:
  - 国际资源访问（中国大陆以外）
  - 备用计算节点
  - 跨区域服务
- **优势**: 访问国际网络更顺畅

### 🔭 SG-2 Recon（GPD MicroPC2）
- **位置**: 移动便携
- **职责**: 移动侦察、离线任务
- **优势**: 便携、可离线工作

---

## 📁 项目结构

```
stargate/
├── README.md                    # 本文件
├── ARCHITECTURE.md              # 架构详细说明
├── DEPLOYMENT.md                # 部署指南
├── configs/
│   ├── sgc-command.yaml         # ⭐ 指挥中心配置 (本地GPU)
│   ├── atlantis-expedition.yaml # 🌊 远征队配置 (腾讯云)
│   └── sg2-recon.yaml           # 🔭 侦察节点配置 (GPD)
├── scripts/
│   ├── install-ollama.sh        # Ollama安装脚本 (仅SG-2)
│   ├── setup-tailscale.sh       # Tailscale组网脚本
│   └── fleet-status.sh          # 舰队状态检查
└── docs/
    ├── MODELS.md                # 模型配置说明
    ├── ROUTING.md               # 任务路由规则
    └── TROUBLESHOOTING.md       # 故障排查
```

---

## 🚀 快速开始

### 1. 网络组网 (Tailscale)

```bash
# 在 SGC Command, Atlantis, SG-2 Recon 都执行
./scripts/setup-tailscale.sh
```

### 2. 安装本地模型 (仅 SG-2)

SGC Command 和 Atlantis 都使用 **API模式**。

```bash
# 仅在 SG-2 Recon 执行 (用于离线模式)
./scripts/install-ollama.sh --profile=recon
```

### 3. 配置 API 密钥

在 **SGC Command** 和 **Atlantis** 上配置 API：

```bash
# 配置智谱AI
openclaw configure --section zai

# 配置Moonshot (可选)
openclaw configure --section moonshot
```

### 4. 应用配置

```bash
# SGC Command (本地GPU服务器)
cp configs/sgc-command.yaml ~/.openclaw/fleet.yaml

# Atlantis Expedition (腾讯云)
cp configs/atlantis-expedition.yaml ~/.openclaw/fleet.yaml

# SG-2 Recon (GPD)
cp configs/sg2-recon.yaml ~/.openclaw/fleet.yaml
```

### 5. 验证部署

```bash
./scripts/fleet-status.sh
```

---

## 📡 任务路由

| 任务类型 | 路由目标 | 说明 |
|----------|----------|------|
| **图像处理** | **⭐SGC Command** | **本地GPU加速** |
| **声音处理** | **⭐SGC Command** | **本地GPU加速** |
| **Embedding** | **⭐SGC Command** | **本地GPU + 大内存** |
| **代码生成** | **⭐SGC Command** | GLM-5 + 72线程编译 |
| **国际资源访问** | **🌊Atlantis** | 海外网络优势 |
| **简单问答** | SGC/Atlantis | API低延迟 |
| **离线任务** | 🔭SG-2 Recon | 本地Phi-3/Qwen1.8B |

---

## 🔧 维护命令

```bash
# 查看舰队状态
openclaw fleet status

# 同步全局记忆
openclaw fleet sync-memory

# 重启所有节点
openclaw fleet restart

# 查看节点日志
openclaw fleet logs --node=sgc-command
```

---

## 📜 命名公约

- 主控Agent: `sgc-command`
- 远征队Agent: `atlantis-expedition`
- 侦察Agent: `sg2-{specialty}`
- 会话标签: `stargate-{mission}-{timestamp}`

---

## 💡 SGC Command 特性（本地GPU服务器）

- **数据安全**: 本地部署，无数据丢失风险
- **GPU计算**: RTX 3060用于图像/声音处理
- **计算优势**: 72线程 Xeon用于并行编译
- **大内存**: 62GB RAM用于大规模数据处理
- **主控中心**: 全局路由和记忆管理

---

## 🌊 Atlantis Expedition 特性（腾讯云新加坡）

- **国际访问**: 便捷访问中国大陆以外资源
- **备用节点**: SGC故障时的备用计算
- **跨区域**: 分布式部署的一部分

---

*"We are the SGC. We are humanity's first line of defense."* 🛸
*"Atlantis, this is SGC. Do you copy?"* 🌊
