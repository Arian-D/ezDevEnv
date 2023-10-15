{
  description = "Helix with all the LSPs";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.helix.url = "github:helix-editor/helix/23.05";

  outputs = { self, nixpkgs, flake-utils, helix }: 
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          hx = helix.packages.${system}.default;
          lsps = with pkgs; [
            marksman
            yaml-language-server
            gopls
            nil
            rust-analyzer
            terraform-ls
          ];
          all-the-packages = [ hx ] ++ lsps;
          env = pkgs.buildEnv {
            name = "ezDevEnv";
            paths = all-the-packages;
            pathsToLink = [ "/bin" ];
          };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = all-the-packages;
        };
        packages.dockerImage = pkgs.dockerTools.buildImage {
          name = "ezDevEnv";
          tag = "latest";
          created = "now";
          copyToRoot = env;
          config.Cmd = [ "/bin/hx" ];
        };
      }
    );
}
