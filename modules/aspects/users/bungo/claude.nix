{...}: {
  bungo.aspects.claude = {
    homeManager = {
      nixpkgs.config.allowUnfree = true;
      programs.claude-code = {
        enable = true;
      };
    };
  };
}
