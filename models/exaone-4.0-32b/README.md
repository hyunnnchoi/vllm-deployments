# EXAONE-4.0-32B Deployment

Docker deployment for LG AI Research's EXAONE-4.0-32B model using custom vLLM.

## Model Information

- **Model ID**: `LGAI-EXAONE/EXAONE-4.0-32B`
- **Parameters**: 32B
- **Served Name**: `EXAONE-4.0-32B`
- **Languages**: Korean, English
- **Provider**: LG AI Research

## Files

- `Dockerfile`: Docker image build configuration

## Build

```bash
docker build --build-arg HF_TOKEN=<your_token> -t vllm-exaone:latest .
```

## Run

```bash
docker run --runtime nvidia --gpus all \
    --name vllm-exaone \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    -p 8000:8000 \
    --ipc=host \
    vllm-exaone:latest
```

## API Example

```bash
curl -X POST "http://localhost:8000/v1/chat/completions" \
    -H "Content-Type: application/json" \
    --data '{
        "model": "EXAONE-4.0-32B",
        "messages": [
            {
                "role": "user",
                "content": "What is the capital of France?"
            }
        ]
    }'
```

## References

- [HuggingFace Model Card](https://huggingface.co/LGAI-EXAONE/EXAONE-4.0-32B)
- [Official vLLM Documentation](https://docs.vllm.ai/)

