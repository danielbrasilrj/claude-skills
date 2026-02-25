# Container Runner Dockerfile

## Dockerfile

```dockerfile
FROM node:20-slim

RUN npm install -g @anthropic-ai/claude-code

RUN useradd -m runner
USER runner
WORKDIR /workspace

ENTRYPOINT ["claude"]
```

## Build and Use

```bash
docker build -t claude-runner:latest .

# Run with isolation
docker run --rm \
  --network=none \
  --memory=512m \
  --cpus=1 \
  --read-only \
  --tmpfs /tmp:size=100m \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  claude-runner:latest \
  -p "Run the test suite" --output-format text
```
