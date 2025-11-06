# vLLM Deployments

Custom vLLM deployment configurations for various language models.

## Overview

This repository contains Docker-based deployment configurations for running various language models using a custom fork of vLLM ([hyunnnchoi/vllm](https://github.com/hyunnnchoi/vllm)).

## Supported Models

### 1. GPT-OSS-20B
- **Model**: `openai/gpt-oss-20b`
- **Location**: `models/gpt-oss-20b/`
- **Features**:
  - LMCache support
  - Debug mode scripts
  - Custom launch configurations

### 2. EXAONE-4.0-32B
- **Model**: `LGAI-EXAONE/EXAONE-4.0-32B`
- **Location**: `models/exaone-4.0-32b/`
- **Features**:
  - 32B parameter model from LG AI Research
  - Optimized for Korean and English

### 3. DeepSeek-R1
- **Model**: TBD
- **Location**: `models/deepseek-r1/`
- **Status**: In development

## Directory Structure

```
vllm-deployments/
├── README.md
└── models/
    ├── gpt-oss-20b/
    │   ├── Dockerfile
    │   ├── README.md
    │   ├── launch-vllm-with-lmcache.sh
    │   ├── launch-vllm-without-lmcache-debug.sh
    │   └── lmcache_config.yaml
    ├── exaone-4.0-32b/
    │   ├── Dockerfile
    │   └── README.md
    └── deepseek-r1/
        ├── Dockerfile
        └── README.md
```

## Usage

### Building Docker Images

```bash
# Build GPT-OSS-20B
cd models/gpt-oss-20b
docker build --build-arg HF_TOKEN=<your_token> -t vllm-gpt-oss:latest .

# Build EXAONE-4.0-32B
cd models/exaone-4.0-32b
docker build --build-arg HF_TOKEN=<your_token> -t vllm-exaone:latest .

# Build DeepSeek-R1
cd models/deepseek-r1
docker build --build-arg HF_TOKEN=<your_token> -t vllm-deepseek:latest .
```

### Running Containers

```bash
# Run with Docker
docker run --runtime nvidia --gpus all \
    --name my_vllm_container \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    -p 8000:8000 \
    --ipc=host \
    vllm-gpt-oss:latest
```

### API Usage

All models expose an OpenAI-compatible API endpoint:

```bash
curl -X POST "http://localhost:8000/v1/chat/completions" \
    -H "Content-Type: application/json" \
    --data '{
        "model": "gpt-oss-20b",
        "messages": [
            {
                "role": "user",
                "content": "Hello, how are you?"
            }
        ]
    }'
```

## Custom vLLM Features

This deployment uses a custom fork of vLLM with the following enhancements:
- LMCache integration for improved caching
- Custom benchmarking tools
- Performance optimizations

The vLLM code is automatically fetched at container startup from [hyunnnchoi/vllm](https://github.com/hyunnnchoi/vllm).

## Requirements

- Docker with NVIDIA GPU support
- NVIDIA GPU with sufficient VRAM
- HuggingFace account and token (for downloading models)

## Configuration

Each model directory contains:
- **Dockerfile**: Container build configuration
- **launch scripts** (optional): Custom startup scripts for various modes
- **config files** (optional): Model-specific configurations (e.g., LMCache)

## Environment Variables

- `HF_TOKEN`: HuggingFace API token (required for model downloads)
- `VLLM_REF`: Git branch/tag to use from custom vLLM repo (default: `main`)

## Notes

- All Dockerfiles use `vllm/vllm-openai:v0.11.0` as the base image
- Models are baked into the Docker image at build time
- GPU memory utilization is set to 0.92 by default
- The custom vLLM code is updated at container startup

## License

Please refer to the respective model licenses and vLLM license.

