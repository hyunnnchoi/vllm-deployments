# export HUGGING_FACE_HUB_TOKEN=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
FROM vllm/vllm-openai:v0.11.0

# ====== 빌드 인자/환경 ======
ARG HF_TOKEN
ARG VLLM_REF=main

ENV HF_TOKEN=${HF_TOKEN} \
    HF_HUB_ENABLE_HF_TRANSFER=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# ====== 필수 도구 ======
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# ====== 의존성 버전 고정 (추가) ======
RUN python3 -m pip install --no-cache-dir -U \
    "huggingface-hub>=0.34.0,<1.0" \
    requests tqdm pandas

# ====== 모델을 이미지에 '굽기' (/model) ======
RUN mkdir -p /model && python3 - <<'PY'
from huggingface_hub import snapshot_download
import os
repo = "K-intelligence/Midm-2.0-Base-Instruct"
snapshot_download(
    repo_id=repo,
    local_dir="/model",
    token=os.environ.get("HF_TOKEN"),
    local_dir_use_symlinks=False
)
PY

# ====== vLLM 레포 전체 클론 ======
# CACHEBUST 인자를 사용하여 이 단계부터 캐시 무효화
ARG CACHEBUST=1
RUN git clone https://github.com/hyunnnchoi/vllm.git /vllm && \
    cd /vllm && \
    git fetch --all && \
    git checkout ${VLLM_REF} || true

# (선택) 레포 내 requirements가 필요하면 활성화
# RUN python3 -m pip install --no-cache-dir -r /vllm/requirements.txt

# 벤치마크 작업 디렉토리
WORKDIR /vllm/benchmarks/multi_turn

# 컨테이너 스타트 시 서버가 즉시 뜨게 (필요 시 served-model-name 변경)
CMD ["--model","/model","--served-model-name","Midm-2.0-Base-Instruct","--dtype","auto","--gpu-memory-utilization","0.92","--api-key","dummy"]