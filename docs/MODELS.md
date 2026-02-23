# 📋 模型配置说明

## 各节点模型策略

| 节点 | 模式 | 主要Provider | 备用Provider | 本地模型 |
|------|------|--------------|--------------|----------|
| **⭐SGC Command** | API | zai/glm-5 | moonshot/k2.5 | 无 (纯API) |
| **🌊Atlantis** | API | kimi-coding/k2.5 | zai/glm-5 | 无 (纯API) |
| **🔭SG-2 Recon** | API+本地 | minimax-cn/MiniMax-M2.5 | zai/glm-4.7 | Phi-3/Qwen1.8B (离线用) |

---

## ⭐ SGC Command 模型配置 (本地GPU服务器)

SGC Command 作为**指挥中心**，使用云端大模型，同时利用本地GPU进行其他计算。

### 主要模型

| 用途 | 模型 | 说明 | 配置 |
|------|------|------|------|
| **主力** | **zai/glm-5** | 智谱最新大模型 | `default` |
| **代码** | **zai/glm-5** | 开启Reasoning模式 | `code` |
| **长文本** | **zai/glm-5** | 200K上下文 | `long_context` |
| **快速** | **zai/glm-4.7-flash** | 低延迟 | `fast` |
| **备选** | **moonshot/k2.5** | Moonshot | `fallback` |

### GPU计算 (非LLM任务)

| 任务 | 用途 | 模型/工具 |
|------|------|-----------|
| **图像生成** | AI绘画 | Stable Diffusion XL |
| **图像处理** | 图像编辑 | ControlNet |
| **语音识别** | 语音转文字 | Whisper Large V3 |
| **语音合成** | 文字转语音 | Bark |
| **文本嵌入** | RAG向量化的 | BGE-Large |

### API配置示例

```yaml
models:
  provider: zai
  default: zai/glm-5
  fallback: moonshot/k2.5
  
  api_config:
    timeout: 120
    retry: 3
    concurrent: 10

gpu_compute:
  enabled: true
  services:
    image_processing: enabled
    audio_processing: enabled
    embedding: enabled
```

---

## 🌊 Atlantis Expedition 模型配置 (腾讯云新加坡)

Atlantis 作为**国际访问节点**，主要使用Moonshot API。

### 主要模型

| 用途 | 模型 | 说明 |
|------|------|------|
| **主力** | **kimi-coding/k2.5** | Moonshot主力模型 |
| **长文本** | **kimi-coding/k2.5** | 262K上下文 |
| **备选** | **zai/glm-5** | 智谱备用 |
| **快速** | **zai/glm-4.7-flash** | 低延迟备选 |

### 国际访问优势

Atlantis位于新加坡，对以下服务访问更顺畅：
- OpenAI API
- HuggingFace
- GitHub
- 国际学术资源

### 配置示例

```yaml
models:
  provider: moonshot
  default: kimi-coding/k2.5
  fallback: zai/glm-5
```

---

## 🔭 SG-2 Recon 本地模型 (离线备份)

SG-2 用于**离线场景**，部署轻量本地模型：

### 轻量模型

| 模型 | 大小 | RAM | 速度 | 用途 |
|------|------|-----|------|------|
| **Phi-3-Mini-3.8B** | ~2.3GB | 2.5GB | 15-20 tok/s | 英文对话 |
| **Qwen2.5-1.8B** | ~1.2GB | 1.5GB | 20-30 tok/s | 中文任务 |
| **TinyLlama-1.1B** | ~0.6GB | 0.8GB | 40-60 tok/s | 极低资源 |

---

## 模型能力对比

| 能力 | GLM-5 (SGC) | K2.5 (Atlantis) | MiniMax (SG-2) |
|------|-------------|-----------------|----------------|
| 代码生成 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 中文理解 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 长上下文 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 推理能力 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 国际访问 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## 故障转移策略

| 场景 | 策略 |
|------|------|
| SGC API失败 | 自动切换到 Moonshot fallback |
| SGC完全故障 | Atlantis接管 (轻量降级模式) |
| Atlantis故障 | SGC直接处理所有任务 |
| 全部API不可用 | 仅SG-2可离线工作 |

---

## API密钥配置

### SGC Command
```bash
openclaw configure --section zai
openclaw configure --section moonshot
```

### Atlantis
```bash
openclaw configure --section moonshot
openclaw configure --section zai
```

---

*"The right model for the right mission, from SGC to Atlantis."* 🛸🌊
