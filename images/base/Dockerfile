# syntax=docker/dockerfile:1
# roxabi-base — Claude Code dev/agent base image
# Consumers: lyra-clipool, any future agent container

FROM node:25-bookworm

LABEL org.opencontainers.image.source="https://github.com/Roxabi/roxabi-container" \
      org.opencontainers.image.description="Node 24 + Python 3.12 + uv + bun + Claude Code agent base"

# ── Package sources ───────────────────────────────────────────────────────────
# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list

# ── System tools ─────────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    git gh ripgrep bash less jq procps sudo ca-certificates \
    unzip gnupg2 fzf iproute2 dnsutils \
    openssh-client rsync \
    make sqlite3 file xz-utils \
    && rm -rf /var/lib/apt/lists/*

# ── uv (manages Python — no system Python install needed) ────────────────────
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Install Python 3.12 to a shared dir and expose as system python3/python
ENV UV_PYTHON_INSTALL_DIR=/usr/local/lib/uv-python
RUN uv python install 3.12 \
    && ln -s "$(uv python find 3.12)" /usr/local/bin/python3 \
    && ln -s "$(uv python find 3.12)" /usr/local/bin/python \
    && chmod -R a+rX /usr/local/lib/uv-python

# ── Node package managers ────────────────────────────────────────────────────
RUN corepack enable \
    && corepack prepare yarn@stable --activate \
    && corepack prepare pnpm@latest --activate

RUN npm install -g bun

# ── Claude Code CLI ──────────────────────────────────────────────────────────
RUN npm install -g @anthropic-ai/claude-code

# ── Default non-root user (UID 1001; node:24-bookworm reserves 1000 for "node") ──
RUN useradd -u 1001 -m -s /bin/bash app \
    && echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/app

USER app

# ── Smoke tests ──────────────────────────────────────────────────────────────
RUN node --version \
    && python3 --version \
    && uv --version \
    && bun --version \
    && git --version \
    && claude --version
