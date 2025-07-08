FROM runpod/base:0.4.0-cuda11.8.0
ENV DEBIAN_FRONTEND=noninteractive
ENV HUGGINGFACE_HUB_CACHE=/models/stt
ENV TTS_HOME=/checkpoints
WORKDIR /app

# Install Python dependencies
COPY builder/requirements.txt /requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r /requirements.txt

# Download Whisper model to local HuggingFace cache
RUN mkdir -p /models/stt && \
    python3.11 -c "from huggingface_hub import snapshot_download; snapshot_download('Systran/faster-whisper-base.en', cache_dir='/models/stt', repo_type='model')"

# Download ChatTTS checkpoint
RUN mkdir -p /checkpoints && \
    python3.11 -c "from huggingface_hub import snapshot_download; snapshot_download('2Noise/ChatTTS', cache_dir='/checkpoints', repo_type='model')"

# Copy application code
ADD src .

# Start RunPod serverless handler
CMD ["python3.11", "-u", "handler.py"]
