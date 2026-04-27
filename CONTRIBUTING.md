# Contributing

## Repository layout

```
images/
  base/           — Claude Code agent base (node:24-bookworm)
  ml-base/        — GPU/ML base (nvidia/cuda)
.github/
  workflows/
    build-base.yml
    build-ml-base.yml
  dependabot.yml  — weekly Docker base image updates
docs/architecture/adr/  — decision log
Makefile          — local build/push shortcuts
```

## Modifying an existing image

1. Edit `images/<name>/Dockerfile`
2. Build and test locally: `make build-<name>`
3. Open a PR to `main` — CI builds the image (does not push from PRs)
4. Merge → CI pushes `:latest`

## Adding a new image

1. Create `images/<name>/Dockerfile` and `images/<name>/.dockerignore`
2. Add a workflow at `.github/workflows/build-<name>.yml` — copy an existing one and update `IMAGE_NAME`, `context`, and path filter
3. Add the image dir to `.github/dependabot.yml`
4. Add `build-<name>` and `push-<name>` targets to `Makefile`
5. Update `README.md` images table
6. Write an ADR in `docs/architecture/adr/` if the new image introduces a non-obvious design choice

## Cutting a versioned release (`roxabi/base`)

```bash
git tag base/vX.Y.Z
git push --tags
```

CI will push both `:vX.Y.Z` and `:latest`. Update consumer Dockerfiles (`lyra`, etc.) to reference the new tag if pinning.

## Cutting a versioned release (`roxabi/ml-base`)

Update `TAG` in `.github/workflows/build-ml-base.yml` and `ML_BASE_TAG` in `Makefile` to match the new component versions, then push to `main`.

## Manual rebuild (without a code change)

Use `workflow_dispatch` from the Actions tab. Optionally pass a `tag` input (e.g. `test`) to push an extra tag alongside `:latest` for validation before promoting.

## Conventions

- One `Dockerfile` per image, in its own directory
- `.dockerignore` must be `**` (blanket deny) for images with no host `COPY` — prevents accidental context leakage
- Smoke tests as the last `RUN` step — fail fast at build time
- OCI labels (`org.opencontainers.image.source`, `description`) on every image
- Non-root default user in every image (`USER app` or equivalent)
- Commits: Conventional (`feat:`, `fix:`, `chore:`)
- ADR for every non-obvious design decision

## Local prerequisites

- Docker or Podman with buildx
- Access to `ghcr.io/roxabi` (for push targets only)
