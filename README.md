# 环境
pip3 install virtualenv

# 拉一个镜像到本地
podman pull --platform linux/amd64 ccr-2vdh3abv-pub.cnc.bj.baidubce.com/paddlepaddle/paddleocr-genai-vllm-server:latest

c2dd37a85fbc5b928d20b0f72232daf9a76e35e0b0749f8e5b9703bf706b5bb6

# 运行
podman run -d --device nvidia.com/gpu=all --gpus all -p 8118:8118 \
   -v $(pwd)/models:/app/models \
   ccr-2vdh3abv-pub.cnc.bj.baidubce.com/paddlepaddle/paddleocr-genai-vllm-server:latest \
    sleep infinity

podman exec -it 3dcae7a2f4338fd3b4a44182b8fc389004f5d046d2151775bbbd74b16158c79f bash

cat > /tmp/vllm_config.json << 'EOF'
{
  "gpu_memory_utilization": 0.7,
  "max_model_len": 2048,
  "max_num_batched_tokens": 2048, 
  "max_num_seqs": 1 
}
EOF

paddleocr genai_server \
  --model_dir /app/models/PaddlePaddle/PaddleOCR-VL-1___5 \
  --model_name PaddleOCR-VL-0.9B \
  --backend vllm \
  --port 8118 \
  --host 0.0.0.0 \
  --backend_config /tmp/vllm_config.json

# 健康检查
curl -i http://localhost:8118/health


# 简单测试
curl http://localhost:8118/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "PaddleOCR-VL-0.9B",
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": "请识别这张图片中的文字。"
          },
          {
            "type": "image_url",
            "image_url": {
              "url": "https://paddle-model-ecology.bj.bcebos.com/paddlex/imgs/demo_image/general_ocr_001.png"
            }
          }
        ]
      }
    ],
    "max_tokens": 1024
  }'

# 一键启动
podman-compose up -d

podman-compose logs -f

podman-compose down