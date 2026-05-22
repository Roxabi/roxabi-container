# syntax=docker/dockerfile:1
# roxabi-base-svc — slim Python 3.12 service runtime base image
# Consumers: lyra hub, telegram, discord adapters (non-agent services)
# Excludes: Node.js, bun, corepack, Claude Code, gh CLI

FROM python:3.12-slim

LABEL org.opencontainers.image.source="https://github.com/Roxabi/roxabi-ml-base" \
      org.opencontainers.image.description="Python 3.12 slim service runtime base (no agent tooling)"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
