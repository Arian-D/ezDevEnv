{
  description = "Helix with all the LSPs";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  # inputs.helix.url = "github:helix-editor/helix/24.03";

  outputs = { self, nixpkgs, flake-utils, helix }: 
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          # TODO: Switch to upstream Helix flake
          # hx = helix.packages.${system}.default;
          hx = pkgs.helix;
          dev-utils = with pkgs; [
            openssl
            pkg-config
            coreutils
            gcc
            bash
            git
            cargo
          ];
          lsps = with pkgs; [
            marksman
            yaml-language-server
            gopls
            nil
            rust-analyzer
            terraform-ls
          ];
          all-the-packages = [ hx ] ++ dev-utils ++ lsps;
          # TODO: Set default CMD
          env = pkgs.buildEnv {
            name = "ezDevEnv";
            paths = all-the-packages;
            pathsToLink = [ "/bin" ];
          };
          dockerImage = pkgs.dockerTools.buildImage {
            name = "ezDevEnv";
            runAsRoot = ''
                #!${pkgs.runtimeShell}
                mkdir -p /tmp
              '';
            tag = "latest";
            created = "now";
            copyToRoot = env;
            config = {
              Volumes = { "/tmp" = { }; "/root" = {}; };
              Env = [
                "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                "HOME=/root"
                "PKG_CONFIG_PATH=${pkgs.openssl.dev}/lib/pkgconfig"
              ];
            };
          };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = all-the-packages;
        };
        packages.environment = env;
        packages.dockerImage = dockerImage;
      }
    );
}
