{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs@{ flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; }
  ({ lib, ... }:
  {
    systems = import inputs.systems;

    perSystem = { pkgs, ... }: {
      packages = rec {
        default = luagit;
        luagit = pkgs.vimUtils.buildVimPlugin {
          pname = "luagit";
          version = "unstable";
          src = lib.cleanSource ./.;
        };
      };
    };
  });
}
