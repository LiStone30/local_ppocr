#!/bin/bash

# 1. 创建 vLLM 配置文件
cat > /tmp/vllm_config.json << 'EOF'
{
  "gpu_memory_utilization": 0.7,
  "max_model_len": 2048,
  "max_num_batched_tokens": 2048,
  "max_num_seqs": 1
}
EOF

# 2. 启动 PaddleOCR-VL 服务 /替换当前进程/
exec paddleocr genai_server \
  --model_dir /app/models/PaddlePaddle/PaddleOCR-VL-1___5 \
  --model_name PaddleOCR-VL-0.9B \
  --backend vllm \
  --port 8118 \
  --host 0.0.0.0 \
  --backend_config /tmp/vllm_config.json