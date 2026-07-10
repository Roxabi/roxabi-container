# syntax=docker/dockerfile:1
# roxabi-ml-base cu130 — shared CUDA 13 + PyTorch for imageCLI (Blackwell / sm_120)
# No flash-attn: imageCLI does not use it; cu130 wheel support is not bundled here.

ARG TORCH_VERSION=2.12.0
ARG TORCHVISION_VERSION=0.27.0

# ── build stage (devel image has nvcc if future extras need compile) ───────────
FROM docker.io/nvidia/cuda:13.2.1-cudnn-devel-ubuntu24.04 AS builder

ARG TORCH_VERSION
ARG TORCHVISION_VERSION

COPY --from=ghcr.io/astral-sh/uv:0.11.7 /uv /uvx /usr/local/bin/

RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-venv python3-dev \
        gcc g++ \
        git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN uv pip install --system --break-system-packages \
        "torch==${TORCH_VERSION}+cu130" \
        "torchvision==${TORCHVISION_VERSION}+cu130" \
        --index-url https://download.pytorch.org/whl/cu130

# ── runtime stage (no compiler toolchain, smaller image) ─────────────────────
FROM docker.io/nvidia/cuda:13.2.1-cudnn-runtime-ubuntu24.04

ARG TORCH_VERSION
ARG TORCHVISION_VERSION

LABEL org.opencontainers.image.source="https://github.com/Roxabi/roxabi-container" \
      org.opencontainers.image.description="CUDA 13 + Python 3.12 + PyTorch ${TORCH_VERSION} cu130 + torchvision ${TORCHVISION_VERSION}" \
      org.opencontainers.image.licenses="MIT"

COPY --from=ghcr.io/astral-sh/uv:0.11.7 /uv /uvx /usr/local/bin/

RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-venv python3-dev \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/lib/python3/dist-packages /usr/lib/python3/dist-packages
COPY --from=builder /usr/local/lib/python3.12/dist-packages /usr/local/lib/python3.12/dist-packages
COPY --from=builder /usr/local/bin /usr/local/bin

RUN python3 -c "import torch; assert torch.version.cuda is not None, 'CUDA not available in torch'; print(f'torch {torch.__version__} cuda {torch.version.cuda}')" && \
    python3 -c "import torchvision; print(f'torchvision {torchvision.__version__}')"