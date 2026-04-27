# CLAUDE.md — roxabi-container

## Project

Container image monorepo for the Roxabi stack.
Builds and publishes `ghcr.io/roxabi/base` and `ghcr.io/roxabi/ml-base`.

## Key files

| File | Role |
|---|---|
| `images/base/Dockerfile` | Claude Code agent base (node:24-bookworm + Python 3.12 + uv + claude CLI) |
| `images/ml-base/Dockerfile` | GPU/ML base (CUDA 12.8.1 + PyTorch 2.7.1 + flash-attn) |
| `.github/workflows/build-base.yml` | CI: push to main + weekly Monday rebuild + git tag releases |
| `.github/workflows/build-ml-base.yml` | CI: push to main only |
| `Makefile` | Local build/push shortcuts |
| `docs/architecture/adr/` | Decision log (ADR-001 → ADR-004) |

## Images

| Image | Base | Consumers |
|---|---|---|
| `ghcr.io/roxabi/base:latest` | `node:24-bookworm` | lyra-clipool |
| `ghcr.io/roxabi/ml-base:latest` | `nvidia/cuda:12.8.1-ubuntu24.04` | voiceCLI, imageCLI |

## Make commands

```bash
make build-base       # build base image locally
make push-base        # build + push :latest
make build-ml-base    # build ml-base (:latest + versioned tag)
make push-ml-base     # build + push both ml-base tags
```

## Releasing

```bash
# base — cut a versioned snapshot
git tag base/v1.0.0 && git push --tags

# ml-base — bump version tag in workflow env + Makefile, push to main
```

## Conventions

- One image per subdirectory under `images/`
- `.dockerignore: **` for every image (no host COPY)
- Smoke test as last `RUN` — verifies toolchain at build time
- Non-root default user in every image
- All tools in `base` intentionally unpinned — weekly CI rebuild is the freshness mechanism
- `ml-base` deps pinned via ARGs — reproducibility over freshness
- ADR for every non-obvious design decision → `docs/architecture/adr/`
- Commits: Conventional (`feat:`, `fix:`, `chore:`)

## Adding a new image

1. `images/<name>/Dockerfile` + `images/<name>/.dockerignore`
2. `.github/workflows/build-<name>.yml` (copy existing, update paths)
3. Add to `dependabot.yml` + `Makefile`
4. Update `README.md`
5. Write an ADR if design is non-obvious

## Open items (follow up)

- ml-base: no non-root user (runs as root in prod)
- ml-base: no git tag trigger for versioned releases
- ml-base: no weekly scheduled rebuild (OS-layer CVEs)
- ADR-004 accepted but not implemented: lyra still references `base:latest` instead of a pinned semantic tag
