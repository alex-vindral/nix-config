{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.nix-secrets.url = lib.mkDefault "git+file:///home/bungo/.nixos/nix-secrets";
  flake-file.inputs.sops-nix = {
    url = lib.mkDefault "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  imports = [(inputs.nix-secrets.flakeModules.default or {})];
}
