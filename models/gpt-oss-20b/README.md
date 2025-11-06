# GPT-OSS-20B Deployment

Docker deployment for OpenAI's GPT-OSS-20B model using custom vLLM.

## Model Information

- **Model ID**: `openai/gpt-oss-20b`
- **Parameters**: 20B
- **Served Name**: `gpt-oss-20b`

## Files

- `Dockerfile`: Docker image build configuration
- `launch-vllm-with-lmcache.sh`: Launch script with LMCache enabled
- `launch-vllm-without-lmcache-debug.sh`: Debug mode without LMCache
- `lmcache_config.yaml`: LMCache configuration

## Build

```bash
docker build --build-arg HF_TOKEN=<your_token> -t vllm-gpt-oss:latest .
```

## Run

```bash
docker run --runtime nvidia --gpus all \
    --name vllm-gpt-oss \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    -p 8000:8000 \
    --ipc=host \
    vllm-gpt-oss:latest
```

## API Example

```bash
curl -X POST "http://localhost:8000/v1/chat/completions" \
    -H "Content-Type: application/json" \
    --data '{
        "model": "gpt-oss-20b",
        "messages": [{"role": "user", "content": "Hello!"}]
    }'
```

