#!/bin/bash

# 절대 경로로 변경
LOG_DIR=/home/xsailor6/hmchoi/vllm_logs

# 디렉토리 생성
mkdir -p $LOG_DIR

# 로그 파일명 (타임스탬프 포함)
LOG_FILE=$LOG_DIR/vllm-midm-$(date +%Y%m%d-%H%M%S).log

# 기존 컨테이너 정리
echo "Stopping and removing existing container..."
sudo docker stop vllm-midm 2>/dev/null
sudo docker rm vllm-midm 2>/dev/null

# 컨테이너 실행
echo "Starting vLLM container..."
sudo docker run -d --name vllm-midm \
  -p 8000:8000 --gpus all --ipc=host \
  -e VLLM_SCHEDULER_CSV_LOG="1" \
  -e VLLM_SCHEDULER_CSV_LOG_DIR="/tmp/vllm_scheduler_logs" \
  potato4332/vllm-midm:v0.11.0-debug \
  --model /model \
  --served-model-name Midm-2.0-Base-Instruct \
  --tensor-parallel-size 4 \
  --gpu-memory-utilization 0.8

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
