#!/bin/bash

# 절대 경로로 변경
LOG_DIR=/home/xsailor6/hmchoi/vllm_logs
CONFIG_DIR=/home/xsailor6/hmchoi/Midm-2.0-Base-Instruct
# LMCache 저장 경로를 용량이 넉넉한 /data 파티션으로 변경
CACHE_DIR=/data/xsailor6/lmcache_storage 

# 디렉토리 생성
mkdir -p $LOG_DIR
mkdir -p $CACHE_DIR 

# 로그 파일명 (타임스탬프 포함)
LOG_FILE=$LOG_DIR/vllm-midm-$(date +%Y%m%d-%H%M%S).log

# 기존 컨테이너 정리
echo "Stopping and removing existing container..."
sudo docker stop vllm-midm 2>/dev/null
sudo docker rm vllm-midm 2>/dev/null


# 컨테이너 실행  
echo "Starting vLLM container..."
sudo docker run -d --name vllm-midm \
  --gpus all --ipc=host -p 8000:8000 \
  -e VLLM_LOGGING_LEVEL=DEBUG \
  -e LMCACHE_CONFIG_FILE=/config_dir/lmcache_config.yaml \
  -e PYTHONHASHSEED=0 \
  -v /home/xsailor6/hmchoi/Midm-2.0-Base-Instruct:/config_dir:ro \
  -v $CACHE_DIR:/lmcache \
  potato4332/vllm-midm:v0.11.0 \
  --model /model \
  --served-model-name Midm-2.0-Base-Instruct \
  --tensor-parallel-size 4 \
  --gpu-memory-utilization 0.8 \
  --kv-transfer-config '{"kv_connector":"LMCacheConnectorV1","kv_role":"kv_both"}'
  
# 컨테이너 시작 대기
echo "Waiting for container to start..."
sleep 5

# 컨테이너 상태 확인
if sudo docker ps | grep -q vllm-midm; then
  echo "Container started successfully!"
  echo "Logs are being saved to: $LOG_FILE"
  echo "Press Ctrl+C to stop following logs (container will keep running)"
  echo "---"
  
  # 로그 파일에 저장하면서 터미널에도 출력
  sudo docker logs -f vllm-midm 2>&1 | tee $LOG_FILE
else
  echo "Failed to start container."
  echo "Checking logs for errors..."
  sudo docker logs vllm-midm 2>&1 | tee $LOG_FILE
  exit 1
fi