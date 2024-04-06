{
  description = "Helix with all the LSPs";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  # inputs.helix.url = "github:helix-editor/helix/24.03";

  outputs = { self, nixpkgs, flake-utils  }: 
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
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
          # TODO: Switch to upstream Helix flake
          hx-with-lsps = pkgs.helix.overrideAttrs (final: prev: {
            postInstall = prev.postInstall + ''
              wrapProgram $out/bin/hx $wrapperfile \
                --suffix PATH : ${pkgs.lib.makeBinPath lsps}
            '';
          });
          helix-config = pkgs.writeTextFile {
            name = "config.toml";
            text = ''
              theme = "catppuccin_macchiato"

              [editor]
              line-number = "relative"
              mouse = true

              [editor.cursor-shape]
              insert = "bar"
              normal = "block"
              select = "underline"

              [editor.file-picker]
              hidden = false
            '';
          };
          hx = pkgs.writeShellScriptBin "hx" ''
            ${hx-with-lsps}/bin/hx --config ${helix-config}
          '';
          all-the-packages = [ hx ] ++ dev-utils;
          # TODO: Set default CMD
          # TODO: Set default WORKDIR
          env = pkgs.buildEnv {
            name = "ezDevEnv";
            paths = all-the-packages;
            pathsToLink = [ "/bin" ];
          };
          dockerImage = pkgs.dockerTools.buildImage {
            name = "ezDevEnv";
            tag = "latest";
            created = "now";
            copyToRoot = env;
            config = {
              Volumes = {
                "/tmp" = {};
                "/root" = {};
              };
              Env = [
                "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                "HOME=/root"
                "PKG_CONFIG_PATH=${pkgs.openssl.dev}/lib/pkgconfig"
                "TERM=xterm-256color"
                "COLORTERM=true"
              ];
            };
          };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = all-the-packages;
        };
        packages.default = hx;
        packages.environment = env;
        packages.dockerImage = dockerImage;
      }
    );
}
