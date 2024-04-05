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

and set this alias to use it easily
```sh
podman run --rm -it -v $PWD:/data ezdevenv:latest hx
```

