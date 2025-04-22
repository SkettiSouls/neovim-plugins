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
      packages = rec {
        luagit = pkgs.vimUtils.buildVimPlugin {
          pname = "luagit";
          version = "unstable";
          src = lib.cleanSource ./luagit;
        };
      };
    };
  });
}
