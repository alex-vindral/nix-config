{...}: {
  bungo.aspects.atuin = {
    homeManager = {
      programs.atuin = {
        enable = true;
        flags = ["--disable-up-arrow"];
      };
    };
  };
}
