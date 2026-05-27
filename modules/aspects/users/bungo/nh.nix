{...}: {
  bungo.aspects.nh = {
    nixos = {
      programs.nh = {
        enable = true;
        flake = "/home/bungo/.nixos/nix-config";
      };
    };
  };
}
