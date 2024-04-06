# Usage
## Nix
Run this to get Helix + some LSPs + my configuration:
```sh
nix run github:Arian-D/ezDevEnv
```
## (WIP) Docker/Podman Container
If you have `nix` (configured with flakes), `podman`, and `git` on your path,
you can run this to build and load the image
```sh
# Build and load
podman load -i $(nix build github:Arian-D/ezDevEnv#dockerImage --print-out-paths)
```

