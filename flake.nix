{
  description = "Helix with all the LSPs";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  # inputs.helix.url = "github:helix-editor/helix/24.03";

  outputs = { self, nixpkgs, flake-utils  }: 
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          lsps = with pkgs; [
            # Markdown 
            marksman
            # YAML
            yaml-language-server
            # Python 
            python312Packages.python-lsp-server
            # Go 
            gopls
            # Nix 
            nil
            # PHP 
            phpactor
            # Rust 
            rust-analyzer
            # Terraform HCL 
            terraform-ls
            # C 
            clang-tools
            # Web 
            vscode-langservers-extracted
            # Lua 
            lua-language-server
            # Dart 
            dart
            # Nushell
            nushellFull
            # Elixir 
            elixir-ls
            # Zig z
            zls
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
              popup-border = "all"

              [editor.lsp]
              display-messages = true
              display-inlay-hints = true

              [editor.cursor-shape]
              insert = "bar"
              normal = "block"
              select = "underline"

              [editor.file-picker]
              hidden = false
              
            '';
          };
          hx = pkgs.writeShellScriptBin "hx" ''
            ${hx-with-lsps}/bin/hx --config ${helix-config} $@
          '';
          extraTools = with pkgs; [
            coreutils
            git
            cargo
          ];
          dockerBuildEnv = pkgs.buildEnv {
            name = "ezdevenv";
            paths = [ hx ] ++ extraTools;
            pathsToLink = [ "/bin" ];
          };
          dockerImage = pkgs.dockerTools.buildImage {
            name = "ezdevenv";
            tag = "latest";
            created = "now";
            copyToRoot = dockerBuildEnv;
            # TODO: Set default WORKDIR
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
        packages.environment = dockerBuildEnv;
        packages.dockerImage = dockerImage;
      }
    );
}
