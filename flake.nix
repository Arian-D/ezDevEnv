{
  description = "Helix with all the LSPs";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  # inputs.helix.url = "github:helix-editor/helix/24.03";

  outputs = { self, nixpkgs, flake-utils  }: 
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
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
              true-color = true
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
          # TODO: Set default WORKDIR
          env = pkgs.buildEnv {
            name = "ezdevenv";
            paths = [ hx ];
            pathsToLink = [ "/bin" ];
          };
          dockerImage = pkgs.dockerTools.buildImage {
            name = "ezdevenv";
            tag = "latest";
            created = "now";
            copyToRoot = env;
            config = {
              Cmd = [ "/bin/hx" ];
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
        packages.default = hx;
        packages.environment = env;
        packages.dockerImage = dockerImage;
      }
    );
}
