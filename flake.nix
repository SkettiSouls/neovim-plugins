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

        mkPlugin = {
          pname,
          version,
          dependencies ? [],
          src ? lib.cleanSource ./${pname},
          ...
        }:
        (buildVimPlugin { inherit pname version src; }).overrideAttrs { inherit dependencies; };
      in {
        luagit = mkPlugin {
          pname = "luagit";
          version = "unstable";
        };

        oil-pushd-nvim = mkPlugin {
          pname = "oil-pushd.nvim";
          version = "unstable";
          src = lib.cleanSource ./oil-pushd;
          dependencies = [ vimPlugins.oil-nvim ];
        };
      };
    };
  });
}
