# Usage
## Nix
```sh
nix develop . -c hx .
```
## Docker/Podman
If you have `nix` (configured with flakes), `podman`, and `git` on your path,
you can run this to build and load the image
```sh
# Build and load
podman load -i $(nix build .#dockerImage --print-out-paths)
```

and then start using this:
```sh
# To do a simple edit
podman run --rm -it --network none -v $PWD:/data ezdevenv hx /data
# To use the shell and developer utilities
podman run --rm -it -v $PWD:/data ezdevenv bash
```

