# Usage
## Nix
```sh
nix develop . -c hx .
```
## Docker/Podman
```sh
# Build
nix build .#dockerImage
# Load
podman load -i result
# Run
podman run --rm -it -v $PWD:/data ezdevenv:latest hx
```

