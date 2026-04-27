# syntax=docker/dockerfile:1
# roxabi-ml-base — shared CUDA + PyTorch + flash-attn base image
# Consumers: voiceCLI, imageCLI (planned)

ARG TORCH_VERSION=2.7.1
ARG TORCHAUDIO_VERSION=2.7.1
ARG FLASH_ATTN_VERSION=2.7.4.post1

# ── build stage (devel image has nvcc for flash-attn compile) ────────────────
FROM docker.io/nvidia/cuda:13.2.1-cudnn-devel-ubuntu24.04 AS builder

ARG TORCH_VERSION
ARG TORCHAUDIO_VERSION
ARG FLASH_ATTN_VERSION

COPY --from=ghcr.io/astral-sh/uv:0.11.7 /uv /uvx /usr/local/bin/

RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-venv python3-dev \
        gcc g++ \
        git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN uv pip install --system --break-system-packages \
        "torch==${TORCH_VERSION}+cu128" \
        "torchaudio==${TORCHAUDIO_VERSION}+cu128" \
        --index-url https://download.pytorch.org/whl/cu128 && \
    uv pip install --system --break-system-packages \
        nvidia-cusparselt-cu12 \
        nvidia-nvshmem-cu12

RUN uv pip install --system --break-system-packages packaging wheel setuptools ninja && \
    uv pip install --system --break-system-packages \
        "flash-attn==${FLASH_ATTN_VERSION}" --no-build-isolation && \
    rm -rf /root/.cache/uv /root/.cache/pip /tmp/*

# ── runtime stage (no compiler toolchain, smaller image) ─────────────────────
FROM docker.io/nvidia/cuda:13.2.1-cudnn-runtime-ubuntu24.04

ARG TORCH_VERSION
ARG FLASH_ATTN_VERSION

LABEL org.opencontainers.image.source="https://github.com/Roxabi/roxabi-ml-base" \
      org.opencontainers.image.description="CUDA 12.8 + Python 3.12 + PyTorch ${TORCH_VERSION} cu128 + flash-attn ${FLASH_ATTN_VERSION}" \
      org.opencontainers.image.licenses="MIT"

COPY --from=ghcr.io/astral-sh/uv:0.11.7 /uv /uvx /usr/local/bin/

RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-venv python3-dev \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy installed site-packages from builder
COPY --from=builder /usr/lib/python3/dist-packages /usr/lib/python3/dist-packages
COPY --from=builder /usr/local/lib/python3.12/dist-packages /usr/local/lib/python3.12/dist-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Smoke test — fails the image if deps are broken
RUN python3 -c "import torch; assert torch.version.cuda is not None, 'CUDA not available in torch'; print(f'torch {torch.__version__} cuda {torch.version.cuda}')" && \
    python3 -c "import torchaudio; print(f'torchaudio {torchaudio.__version__}')" && \
    python3 -c "import flash_attn; print(f'flash_attn {flash_attn.__version__}')"
