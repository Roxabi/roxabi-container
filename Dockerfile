# syntax=docker/dockerfile:1
# roxabi-ml-base — shared CUDA + PyTorch + flash-attn base image
# Consumers: voiceCLI, imageCLI (planned)
FROM docker.io/nvidia/cuda:12.8.1-cudnn9-runtime-ubuntu24.04

ARG PYTHON_VERSION=3.12
ARG TORCH_VERSION=2.7.1
ARG TORCHAUDIO_VERSION=2.7.1
ARG FLASH_ATTN_VERSION=2.7.4
ARG UV_VERSION=0.11.7

LABEL org.opencontainers.image.source="https://github.com/Roxabi/roxabi-ml-base" \
      org.opencontainers.image.description="CUDA 12.8 + Python 3.12 + PyTorch ${TORCH_VERSION} cu128 + flash-attn ${FLASH_ATTN_VERSION}" \
      org.opencontainers.image.licenses="MIT"

# uv from official OCI artifact
COPY --from=ghcr.io/astral-sh/uv:0.11.7 /uv /uvx /usr/local/bin/

# System deps: Python + build toolchain for flash-attn wheel
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-venv python3-dev \
        gcc g++ \
        git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install torch + torchaudio + flash-attn into system site-packages
RUN uv pip install --system --break-system-packages \
        "torch==${TORCH_VERSION}+cu128" \
        "torchaudio==${TORCHAUDIO_VERSION}+cu128" \
        --index-url https://download.pytorch.org/whl/cu128 && \
    uv pip install --system --break-system-packages \
        "flash-attn==${FLASH_ATTN_VERSION}" --no-build-isolation && \
    rm -rf /root/.cache/uv /root/.cache/pip /tmp/*

# Smoke test baked into build — fails the image if deps are broken
RUN python3 -c "import torch; assert torch.version.cuda is not None, 'CUDA not available in torch'; print(f'torch {torch.__version__} cuda {torch.version.cuda}')" && \
    python3 -c "import torchaudio; print(f'torchaudio {torchaudio.__version__}')" && \
    python3 -c "import flash_attn; print(f'flash_attn {flash_attn.__version__}')"
