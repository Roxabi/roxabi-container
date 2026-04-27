# syntax=docker/dockerfile:1
# roxabi-base — Claude Code dev/agent base image
# Consumers: lyra-clipool, any future agent container

FROM node:24-bookworm

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
    # Claude Code hard requirements
    git gh ripgrep bash less jq procps sudo ca-certificates \
    unzip gnupg2 fzf iproute2 dnsutils \
    # SSH + file sync (deploy scripts across projects)
    openssh-client rsync \
    # Common build/project tools
    make sqlite3 file xz-utils \
    # Python 3.12 (from backports — bookworm ships 3.11)
    && apt-get install -y -t bookworm-backports --no-install-recommends \
    python3.12 python3.12-dev python3.12-venv \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 \
    && rm -rf /var/lib/apt/lists/*

# ── uv 0.11.7 ────────────────────────────────────────────────────────────────
COPY --from=ghcr.io/astral-sh/uv:0.11.7 /uv /uvx /usr/local/bin/

# ── Node package managers ────────────────────────────────────────────────────
RUN corepack enable \
    && corepack prepare yarn@1.22.22 --activate \
    && corepack prepare pnpm@10.33.2 --activate

# bun 1.3.13
RUN npm install -g bun@1.3.13

# ── Claude Code 2.1.119 ──────────────────────────────────────────────────────
RUN npm install -g @anthropic-ai/claude-code@2.1.119

# ── Smoke tests ──────────────────────────────────────────────────────────────
RUN node --version \
    && python3 --version \
    && uv --version \
    && bun --version \
    && git --version \
    && claude --version
