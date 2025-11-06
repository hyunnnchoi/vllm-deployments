FROM vllm/vllm-openai:v0.11.0

# ====== Build arguments / environment ======
ARG HF_TOKEN
ARG VLLM_REF=main

ENV HF_TOKEN="${HF_TOKEN}" \
    HF_HUB_ENABLE_HF_TRANSFER=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VLLM_DECODE_TIMINGS_DIR=/vllm-workspace/benchmarks/multi_turn/decode_timings

# ====== Base tools ======
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# ====== Python dependencies ======
RUN python3 -m pip install --no-cache-dir -U \
    "huggingface-hub>=0.34.0,<1.0" \
    requests tqdm pandas

# ====== Bake model into image (/model) ======
# [NOTE, hyunnnchoi, 2025.11.06] Changed model repository to deepseek-ai/DeepSeek-R1-Distill-Qwen-32B
RUN mkdir -p /model && python3 - <<'PY'
from huggingface_hub import snapshot_download
import os

repo = "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B"
snapshot_download(
    repo_id=repo,
    local_dir="/model",
    token=os.environ.get("HF_TOKEN"),
    local_dir_use_symlinks=False,
)
PY

# ====== Clone vLLM repo (initial) ======
# 최초 빌드 시에만 클론 (부팅 시 스크립트에서 업데이트됨)
RUN git clone https://github.com/hyunnnchoi/vllm.git /vllm || true

# ====== Install editable vLLM (initial) ======
WORKDIR /vllm
RUN python3 -m pip uninstall -y vllm || true && \
    python3 -m pip install --no-cache-dir -e ".[all]"

# Prepare directories for decode timing outputs
RUN mkdir -p /vllm-workspace/benchmarks/multi_turn/decode_timings

# ====== Default working directory for benchmarks ======
WORKDIR /vllm/benchmarks/multi_turn

# ====== Startup script to fetch latest code ======
ARG START_SCRIPT_CACHEBUST=1
RUN cat <<EOF >/start.sh
#!/bin/bash
set -e
echo "=== Updating vLLM code ==="
cd /vllm
git fetch --all
git reset --hard origin/\${VLLM_REF:-main}
git checkout \${VLLM_REF:-main}
echo "=== Current commit: \$(git rev-parse HEAD) ==="
echo "=== Starting vLLM server ==="
cd /vllm/benchmarks/multi_turn
# cachebust: \${START_SCRIPT_CACHEBUST}
exec python3 -m vllm.entrypoints.openai.api_server "\$@"
EOF
RUN chmod +x /start.sh

# ====== Use custom entrypoint ======
# [NOTE, hyunnnchoi, 2025.11.06] Updated served-model-name to DeepSeek-R1-Distill-Qwen-32B
ENTRYPOINT ["/start.sh"]
CMD ["--model","/model","--served-model-name","DeepSeek-R1-Distill-Qwen-32B","--dtype","auto","--gpu-memory-utilization","0.92","--api-key","dummy"]