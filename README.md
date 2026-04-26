# roxabi-ml-base

Shared CUDA + PyTorch base image for Roxabi ML projects.

```
ghcr.io/roxabi/ml-base:cu128-py312-torch2.7.1
```

## Contents

| Component | Version |
|---|---|
| CUDA | 12.8.1 (cuDNN 9, runtime) |
| Python | 3.12 (Ubuntu 24.04 native) |
| PyTorch | 2.7.1+cu128 |
| torchaudio | 2.7.1+cu128 |
| flash-attn | 2.7.4 |

## Tags

| Tag | Use case |
|---|---|
| `cu128-py312-torch2.7.1` | Exact-patch — pin this in prod Dockerfiles |
| `latest` | Dev convenience only — never pin in prod |
| `buildcache` | GHA registry cache, internal |

Floating-minor tags (e.g. `torch2.7`) are **not published** — a 2.7.x patch could introduce ABI changes that silently break downstream consumers.

## Consumers

| Project | Status |
|---|---|
| [voiceCLI](https://github.com/Roxabi/voiceCLI) | Active |
| imageCLI | Planned |

## Governance

Bumping the torch version in this image requires sign-off from every known consumer listed above. Open a discussion issue and tag each consumer's maintainer before merging a version bump.

## Local build

```bash
podman build -t ml-base:local .
podman run --rm --gpus all ml-base:local python3 -c "
import torch; print('torch', torch.__version__, torch.cuda.is_available(), torch.cuda.get_device_capability(0))
import flash_attn; print('flash_attn', flash_attn.__version__)
"
```

## Rebuild

Push to `main` triggers the GHA workflow. For manual rebuilds, use `workflow_dispatch` from the Actions tab.

## License

MIT
