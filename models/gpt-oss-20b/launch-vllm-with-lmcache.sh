#!/bin/bash

# 절대 경로로 변경
LOG_DIR=/home/xsailor6/hmchoi/vllm_logs
CONFIG_DIR=/home/xsailor6/hmchoi/vllm-gpt-oss
CACHE_DIR=/home/xsailor6/hmchoi/lmcache_storage

# 디렉토리 생성
mkdir -p $LOG_DIR
mkdir -p $CACHE_DIR

# 로그 파일명 (타임스탬프 포함)
LOG_FILE=$LOG_DIR/vllm-gpt-oss-$(date +%Y%m%d-%H%M%S).log

# 기존 컨테이너 정리
echo "Stopping and removing existing container..."
sudo docker stop vllm-gpt-oss 2>/dev/null
sudo docker rm vllm-gpt-oss 2>/dev/null

# 컨테이너 실행
echo "Starting vLLM container..."
sudo docker run -d --name vllm-gpt-oss \
  --gpus all --ipc=host -p 8000:8000 \
  -e VLLM_LOGGING_LEVEL=DEBUG \
  -e LMCACHE_CONFIG_FILE=/config_dir/lmcache_config.yaml \
  -e PYTHONHASHSEED=0 \
  -v /home/xsailor6/hmchoi/vllm-gpt-oss:/config_dir:ro \
  -v /home/xsailor6/hmchoi/lmcache_storage:/lmcache \
  potato4332/vllm-gpt-oss:v0.0.1 \
  --model /model \
  --served-model-name gpt-oss-20b \
  --tensor-parallel-size 4 \
  --gpu-memory-utilization 0.8 \
  --kv-transfer-config '{"kv_connector":"LMCacheConnectorV1","kv_role":"kv_both"}'

# 컨테이너 시작 대기
echo "Waiting for container to start..."
sleep 5

# 컨테이너 상태 확인
if sudo docker ps | grep -q vllm-gpt-oss; then
  echo "Container started successfully!"
  echo "Logs are being saved to: $LOG_FILE"
  echo "Press Ctrl+C to stop following logs (container will keep running)"
  echo "---"
  
  # 로그 파일에 저장하면서 터미널에도 출력
  sudo docker logs -f vllm-gpt-oss 2>&1 | tee $LOG_FILE
else
  echo "Failed to start container."
  echo "Checking logs for errors..."
  sudo docker logs vllm-gpt-oss 2>&1 | tee $LOG_FILE
  exit 1
fi
