#!/bin/bash
# [NOTE, hyunnnchoi, 2025.11.13] Standalone 벤치마크 스크립트 (서버 없이 직접 모델 로드하여 latency 측정)

# 기존 컨테이너 정지 및 삭제
sudo docker stop vllm 2>/dev/null
sudo docker rm vllm 2>/dev/null

# nsys 리포트 저장 디렉토리 생성
mkdir -p nsys_reports

# standalone 벤치마크 실행 (서버 없이 직접 모델 로드)
# nsys profile로 프로파일링하면서 벤치마크 실행
# nsys가 컨테이너에 없으면 설치 시도 후 실행
sudo docker run --rm --gpus all --ipc=host \
  -e HF_TOKEN=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 \
  -v $(pwd)/nsys_reports:/workspace/nsys_reports \
  --entrypoint bash \
  vllm/vllm-openai:v0.11.0 \
  -c "if ! command -v nsys &> /dev/null; then \
        echo 'nsys not found. Installing nsight-systems from apt...'; \
        apt-get update && \
        apt-get install -y --no-install-recommends nsight-systems-cli || \
        (echo 'Installing from NVIDIA repo...'; \
         apt-get install -y wget ca-certificates && \
         wget -qO - https://developer.download.nvidia.com/devtools/repos/ubuntu2204/amd64/nvidia.pub | apt-key add - && \
         echo 'deb https://developer.download.nvidia.com/devtools/repos/ubuntu2204/amd64/ /' > /etc/apt/sources.list.d/nsight.list && \
         apt-get update && \
         apt-get install -y nsight-systems-cli); \
      fi && \
      nsys profile \
        --trace-fork-before-exec=true \
        --cuda-graph-trace=node \
        --output=/workspace/nsys_reports/vllm_bench \
        vllm bench latency \
          --model meta-llama/Llama-3.2-1B \
          --tensor-parallel-size 4 \
          --num-iters-warmup 5 \
          --num-iters 1 \
          --batch-size 16 \
          --input-len 512 \
          --output-len 8 \
          --gpu-memory-utilization 0.95"