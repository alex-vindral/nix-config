{...}: {
  flake-file.inputs = {
    nix-nvim = {
      url = "github:buungoo/nix-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  bungo.aspects.wireguard = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.wireguard-tools];
    };
  };
}
