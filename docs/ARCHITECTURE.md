# 🏛️ Stargate SGC 架构设计 (更新版)

## 1. 设计哲学

### 星际之门类比

| Stargate概念 | OpenClaw映射 | 说明 |
|--------------|--------------|------|
| **SGC (Stargate Command)** | 本地GPU服务器 | 指挥中心，最安全，有GPU计算能力 |
| **Atlantis Expedition** | 腾讯云新加坡 | 海外前哨站，访问国际资源 |
| **SG-2 Recon** | GPD MicroPC2 | 移动侦察队，便携离线 |
| **Stargate** | Tailscale VPN | 跨节点安全通信 |
| **Off-world Missions** | 分布式任务 | 跨节点协作 |

### 核心原则

1. **数据安全第一**: SGC Command在本地，数据不会丢失
2. **国际访问**: Atlantis在新加坡，便捷访问海外资源
3. **计算分离**: GPU计算在本地，API推理按需分配
4. **离线韧性**: SG-2可在无网络时独立工作

---

## 2. 节点详细规格

### ⭐ SGC Command (指挥中心) - 本地GPU服务器

```yaml
node_id: sgc-command
host: ZD-PC
location: 本地WSL2 (最安全)
role: command_center + gpu_compute_center
profile: api_with_gpu

hardware:
  cpu: Intel Xeon E5-2695 v4 @ 2.10GHz (36C/72T)
  ram: 62 GB DDR4
  gpu: NVIDIA RTX 3060 Laptop 12GB GDDR6
  storage: 1TB NVMe
  
software:
  os: Ubuntu 22.04.5 LTS (WSL2)
  openclaw: 2026.2.22
  
models:
  api_mode:
    primary: zai/glm-5
    fallback: moonshot/k2.5
  local_llm: disabled  # 纯API模式
  
gpu_compute:
  image_processing: enabled    # 图像生成/处理
  audio_processing: enabled    # 语音识别/合成
  embedding: enabled           # 本地Embedding
  local_ml: enabled            # 其他ML任务
  
capabilities:
  - command_center:            # 指挥中心
      routing: true
      memory_master: true
      
  - api_inference:             # API推理
      provider: zai/moonshot
      
  - gpu_compute:               # GPU计算
      vram: 12GB
      cuda: "12.4"
      
  - code_generation:           # 代码生成
      compile_threads: 64
      
  - large_rag:                 # 大文档处理
      max_document: 100MB
      memory: 56GB
      
  - external_interface:        # 外部接口
      qqbot: enabled
      discord: enabled

responsibilities:
  - 任务路由和分配
  - 全局记忆管理 (MEMORY.md主库)
  - GPU计算 (图像/声音/Embedding)
  - 代码生成和编译 (72线程)
  - 长文档分析
  - 外部消息接口 (QQ/Discord)
  - 数据备份中心
  
advantages:
  - 数据安全: 本地存储，不会丢失
  - GPU加速: 图像/声音处理
  - 大内存: 62GB用于大数据处理
  - 多线程: 72线程并行编译
```

### 🌊 Atlantis Expedition (远征队) - 腾讯云新加坡

```yaml
node_id: atlantis-expedition
host: VM-0-2-opencloudos
location: Tencent Cloud Singapore (海外节点)
role: expedition_node
profile: api_only

hardware:
  cpu: 2 vCPU (AMD EPYC 7K62)
  ram: 2 GB
  gpu: none
  storage: 50GB SSD
  
software:
  os: OpenCloudOS 9
  openclaw: 2026.2.9
  
models:
  api_mode:
    primary: kimi-coding/k2.5
    fallback: zai/glm-5
  local_llm: disabled
  
capabilities:
  - international_access:      # 国际资源访问
      web_fetch: true
      api_access: true
      content_download: true
      
  - api_inference:             # API推理 (备用)
      provider: moonshot
      
  - backup_compute:            # 备用计算
      description: "SGC故障时接管"
      
  - light_tasks:               # 轻量任务
      max_tokens: 20000

responsibilities:
  - 访问中国大陆以外的资源
  - 国际网站内容抓取
  - SGC故障时的备用计算节点
  - 跨区域服务
  
advantages:
  - 网络位置: 访问国际资源更顺畅
  - 备用节点: 高可用性
  - 低延迟: 对国际API延迟更低
  
limitations:
  - 轻量节点: 2vCPU/2GB，不适合重任务
  - 云端风险: 数据可能丢失 (不保存敏感数据)
```

### 🔭 SG-2 Recon (侦察兵) - GPD MicroPC2

```yaml
node_id: sg2-recon
host: DESKTOP-1156LM3
location: GPD MicroPC2 (移动便携)
role: mobile_recon
profile: api_with_offline

hardware:
  cpu: Intel N250 (4C/4T)
  ram: 7.6 GB
  gpu: none
  storage: 1TB SSD
  
software:
  os: Ubuntu 22.04.2 LTS (WSL2)
  openclaw: 2026.2.22-2
  
models:
  api_mode:
    primary: minimax-cn/MiniMax-M2.5
    fallback: zai/glm-4.7
  local_models:                # 离线使用
    - phi3:mini (3.8B)
    - qwen2.5:1.8b
    - tinyllama:1.1b
  
capabilities:
  - offline_inference:         # 离线推理
      max_model_size: 4B
      ram_limit: 5GB
      
  - portable_operation:        # 便携操作
      battery_aware: true
      
  - browser_automation:        # 浏览器自动化
      chromium: enabled
      headless: true

responsibilities:
  - 移动场景任务
  - 离线轻量推理
  - 外出演示支持
  - 紧急备用节点
  
advantages:
  - 便携: 掌上PC，随身携带
  - 离线: 无网络时可独立工作
  - 低调: 不引人注目
```

---

## 3. 网络拓扑

### Tailscale Mesh VPN

```
                    Internet
                       │
    ┌──────────────────┼──────────────────┐
    │                  │                  │
    ▼                  ▼                  ▼
┌─────────┐      ┌─────────┐      ┌─────────┐
│  ⭐SGC  │◄────►│  🌊ATL  │◄────►│  🔭SG2  │
│ Command │      │Expedition      │  Recon  │
│100.64.0.1      │100.64.0.2      │100.64.0.3│
│本地GPU   │      │新加坡    │      │移动     │
└────┬────┘      └─────────┘      └─────────┘
     │
     ▼
  QQ/Discord (用户入口)
```

---

## 4. 数据流

### 4.1 正常任务流

```
用户 (QQ/Discord)
    │
    ▼
[SGC Command] 接收并评估
    │
    ├──► GPU计算任务 ────────► SGC本地处理 (图像/声音/Embedding)
    │
    ├──► 代码/文档任务 ──────► SGC本地处理 (API + 72线程编译)
    │
    ├──► 国际资源访问 ───────► Atlantis Expedition
    │
    ├──► 轻量备份任务 ───────► Atlantis (SGC忙时)
    │
    └──► 离线/移动任务 ──────► SG-2 Recon
```

### 4.2 数据同步流

```
[SGC Command - MEMORY.md主库]
    │
    ├──► 同步到 Atlantis (定期备份)
    │
    └──► 同步到 SG-2 (必要时)
```

### 4.3 故障转移

| 故障节点 | 转移目标 | 策略 |
|----------|----------|------|
| SGC Command | Atlantis | Atlantis接管路由 (轻量降级) |
| Atlantis | SGC Command | SGC直接处理所有任务 |
| SG-2 | SGC/Atlantis | 不可用，需等待恢复 |

---

## 5. 安全考虑

### 数据安全层级

| 节点 | 安全级别 | 说明 |
|------|----------|------|
| **SGC Command** | ⭐⭐⭐⭐⭐ | 本地物理控制，最安全 |
| **SG-2 Recon** | ⭐⭐⭐⭐ | 本地设备，随身携带 |
| **Atlantis** | ⭐⭐⭐ | 云端，定期备份到SGC，不存敏感数据 |

### 敏感数据处理

- **MEMORY.md**: 只在SGC Command主库存储
- **API密钥**: 各节点独立管理
- **用户数据**: 优先在SGC处理，Atlantis只读缓存

---

## 6. 为什么选择这种架构

### SGC Command在本地的原因

1. **数据安全**: 火山云重启后OpenClaw丢失的教训
2. **GPU利用**: 本地GPU可做图像/声音处理
3. **大内存**: 62GB RAM处理大文档
4. **编译加速**: 72线程并行编译

### Atlantis在新加坡的原因

1. **国际访问**: 访问OpenAI、HuggingFace等更顺畅
2. **网络位置**: 对中国大陆以外API延迟更低
3. **备用节点**: SGC故障时的fallback
4. **轻量设计**: 2vCPU/2GB足够API调用

---

*"SGC to Atlantis, come in."* 🛸🌊
