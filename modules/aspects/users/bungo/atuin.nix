{...}: {
  bungo.aspects.atuin = {
    homeManager = {
      programs.atuin = {
        enable = true;
        flags = ["--disable-up-arrow"];
        settings = {
          enter_accept = true;
          ai = {
            enabled = true;
          };
        };
      };
    };
  };
}
