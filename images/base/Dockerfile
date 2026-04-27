# syntax=docker/dockerfile:1
# roxabi-base — Claude Code dev/agent base image
# Consumers: lyra-clipool, any future agent container

FROM node:24-bookworm

LABEL org.opencontainers.image.source="https://github.com/Roxabi/roxabi-container" \
      org.opencontainers.image.description="Node 24 + Python 3.12 + uv + bun + Claude Code agent base"

# ── Package sources ───────────────────────────────────────────────────────────
# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list

# Backports for Python 3.12 (Bookworm default is 3.11)
RUN echo "deb http://deb.debian.org/debian bookworm-backports main" \
        > /etc/apt/sources.list.d/backports.list

# ── System tools ─────────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    git gh ripgrep bash less jq procps sudo ca-certificates \
    unzip gnupg2 fzf iproute2 dnsutils \
    openssh-client rsync \
    make sqlite3 file xz-utils \
    && apt-get install -y -t bookworm-backports --no-install-recommends \
    python3.12 python3.12-dev python3.12-venv \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 \
    && rm -rf /var/lib/apt/lists/*

# ── uv ───────────────────────────────────────────────────────────────────────
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# ── Node package managers ────────────────────────────────────────────────────
RUN corepack enable \
    && corepack prepare yarn@stable --activate \
    && corepack prepare pnpm@latest --activate

RUN npm install -g bun

# ── Claude Code CLI ──────────────────────────────────────────────────────────
RUN npm install -g @anthropic-ai/claude-code

# ── Default non-root user (consumers override with their own UID if needed) ──
RUN useradd -u 1000 -m -s /bin/bash app \
    && echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/app

USER app

# ── Smoke tests ──────────────────────────────────────────────────────────────
RUN node --version \
    && python3 --version \
    && uv --version \
    && bun --version \
    && git --version \
    && claude --version
