{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.nix-secrets.url = lib.mkDefault "git+ssh://git@github.com/alex-vindral/nix-secrets.git";
  flake-file.inputs.sops-nix = {
    url = lib.mkDefault "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  imports = [(inputs.nix-secrets.flakeModules.default or {})];
}
