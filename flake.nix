{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; }
  ({ lib, ... }:
  {
    systems = [ "x86_64-linux" "aarch64-linux" ];

    perSystem = { pkgs, ... }: {
      packages = let
        inherit (pkgs) vimPlugins;
        inherit (pkgs.vimUtils) buildVimPlugin;

        oil-pushd-nvim = buildVimPlugin {
          pname = "oil-pushd.nvim";
          version = "unstable";
          src = lib.cleanSource ./oil-pushd;
        };
      in {
        luagit = buildVimPlugin {
          pname = "luagit";
          version = "unstable";
          src = lib.cleanSource ./luagit;
        };

        oil-pushd-nvim = oil-pushd-nvim.overrideAttrs {
          dependencies = [ vimPlugins.oil-nvim ];
        };
      };
    };
  });
}
