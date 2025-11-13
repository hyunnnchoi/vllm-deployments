#!/bin/bash
# [NOTE, hyunnnchoi, 2025.11.13] Custom vllm + LMCache image without baked model

set -e

# [NOTE, hyunnnchoi, 2025.11.13] Basic configuration
IMAGE_NAME="${IMAGE_NAME:-potato4332/vanilla-vllm:v0.11.0}"
# MODEL_NAME="${MODEL_NAME:-meta-llama/Llama-3.2-1B}"
MODEL_NAME="${MODEL_NAME:-facebook/opt-6.7b}"
# MODEL_NAME="${MODEL_NAME:-facebook/opt-13b}"
# MODEL_NAME="${MODEL_NAME:-meta-llama/Llama-2-13b}"
# MODEL_NAME="${MODEL_NAME:-meta-llama/Llama-2-7b}"
# MODEL_NAME="${MODEL_NAME:-lmsys/vicuna-13b-v1.5}"
HF_TOKEN="${HF_TOKEN:-}"
VLLM_REF="${VLLM_REF:-main}"
LMCACHE_REF="${LMCACHE_REF:-dev}"
ENABLE_NSYS="${ENABLE_NSYS:-false}"

# [NOTE, hyunnnchoi, 2025.11.13] Stop and remove existing container
sudo docker stop vllm 2>/dev/null || true
sudo docker rm vllm 2>/dev/null || true

# [NOTE, hyunnnchoi, 2025.11.13] Create log and report directories
mkdir -p vllm_logs
mkdir -p nsys_reports

# [NOTE, hyunnnchoi, 2025.11.13] Start vLLM server with TP=4
sudo docker run -d --name vllm --gpus all --ipc=host \
  -p 8000:8000 \
  -v /home/xsailor6/hmchoi/ELIS/data:/data \
  -e HF_TOKEN="${HF_TOKEN}" \
  -e VLLM_REF=${VLLM_REF} \
  -e LMCACHE_REF=${LMCACHE_REF} \
  -e VLLM_LOGGING_LEVEL=DEBUG \
  ${IMAGE_NAME} \
  vllm serve ${MODEL_NAME} \
  --tensor-parallel-size 4 \
  --gpu-memory-utilization 0.8

# [NOTE, hyunnnchoi, 2025.11.13] Follow logs in real-time
sudo docker logs -f vllm
