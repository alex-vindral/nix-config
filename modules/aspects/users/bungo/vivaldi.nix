{...}: {
  bungo.aspects.vivaldi = {
    nixos = {
      nixpkgs.config.allowUnfree = true;
    };

    homeManager = {
      nixpkgs.config.allowUnfree = true;
      programs.vivaldi = {
        enable = true;
      };
    };
  };
}
