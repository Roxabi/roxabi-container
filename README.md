# roxabi-container

Container image monorepo for the Roxabi stack. Builds and publishes base images to `ghcr.io/roxabi/`.

## Images

| Image | Base | Purpose | Consumers |
|---|---|---|---|
| [`roxabi/base`](images/base/Dockerfile) | `node:24-bookworm` | Claude Code agent runtime — Node 24, Python 3.12, uv, bun, yarn, pnpm, gh, ripgrep, claude CLI | lyra-clipool |
| [`roxabi/ml-base`](images/ml-base/Dockerfile) | `nvidia/cuda:12.8.1` | GPU/ML runtime — CUDA 12.8, PyTorch 2.7.1+cu128, flash-attn | voiceCLI, imageCLI |

## Getting started

### Pull an image

```bash
# Agent base (Claude Code dev environment)
docker pull ghcr.io/roxabi/base:latest

# ML/GPU base
docker pull ghcr.io/roxabi/ml-base:latest
# or pin to exact version
docker pull ghcr.io/roxabi/ml-base:cu128-py312-torch2.7.1
```

### Use as a base in your Dockerfile

```dockerfile
# Agent container
FROM ghcr.io/roxabi/base:latest
USER root
RUN useradd -u 1500 -m myapp
COPY --chown=myapp:myapp . /app
USER myapp

# ML/GPU container
ARG ML_BASE_TAG=cu128-py312-torch2.7.1
FROM ghcr.io/roxabi/ml-base:${ML_BASE_TAG}
```

### Local build

```bash
make build-base       # build roxabi/base:latest
make build-ml-base    # build roxabi/ml-base:latest + versioned tag
make push-base        # build + push roxabi/base:latest
make push-ml-base     # build + push roxabi/ml-base both tags
```

## Tag strategy

### `roxabi/base`

| Tag | When | Use |
|---|---|---|
| `:latest` | Every push to `main`, weekly schedule | Dev / local pulls |
| `:vX.Y.Z` | Git tag `base/vX.Y.Z` | Pinned prod snapshot |
| `:<custom>` | Manual `workflow_dispatch` with tag input | Testing before release |

Cut a versioned release:
```bash
git tag base/v1.0.0
git push --tags
```

### `roxabi/ml-base`

| Tag | When | Use |
|---|---|---|
| `:latest` | Every push to `main` | Dev convenience |
| `:cu128-py312-torch2.7.1` | Every push to `main` | Pin this in prod Dockerfiles |

## `roxabi/base` — what's included

| Category | Tools |
|---|---|
| Runtime | Node 24, Python 3.12 |
| Package managers | npm, yarn, pnpm (corepack), bun |
| Python tooling | uv, uvx |
| Claude Code | `claude` CLI (always latest — weekly rebuild keeps it fresh) |
| Dev tools | git, gh, ripgrep, fzf, jq, make, sqlite3, rsync, ssh-client |
| Network | curl, iproute2, dnsutils, ca-certificates |
| Default user | `app` (UID 1000, NOPASSWD sudo) |

## `roxabi/ml-base` — what's included

| Component | Version |
|---|---|
| CUDA | 12.8.1 (cuDNN 9, runtime) |
| Python | 3.12 (Ubuntu 24.04) |
| PyTorch | 2.7.1+cu128 |
| torchaudio | 2.7.1+cu128 |
| flash-attn | 2.7.4.post1 |
| uv | 0.11.7 |

## CI

Both images use registry-cached GitHub Actions builds (`mode=max`). Workflows trigger independently via path filters — a change to `images/base/**` never rebuilds ml-base.

`roxabi/base` rebuilds automatically every Monday 04:00 UTC to pick up the latest `claude-code`, `uv`, `bun`, and `node:24` patch.

## Architecture decisions

Design choices are documented in [`docs/architecture/adr/`](docs/architecture/adr/):

- [ADR-001](docs/architecture/adr/001-container-image-monorepo.mdx) — Monorepo vs separate repos
- [ADR-002](docs/architecture/adr/002-node-first-base-image.mdx) — Node-first base image
- [ADR-003](docs/architecture/adr/003-claude-code-cli-in-base-image.mdx) — Claude Code CLI in base
- [ADR-004](docs/architecture/adr/004-base-image-tagging-strategy.mdx) — Tagging strategy

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT
