{...}: {
  bungo.aspects.git = {
    homeManager = {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "Alex Bergdahl";
            email = "alex.bergdahl@vindral.com";
          };
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
        };
      };

      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          navigate = true;
          line-numbers = true;
          side-by-side = true;
        };
      };
    };
  };
}
