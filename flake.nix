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
            rust-analyzer
            terraform-ls
          ];
          all-the-packages = [ hx ] ++ lsps;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = all-the-packages;
        };
      }
    );
}
