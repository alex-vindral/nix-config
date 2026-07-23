{...}: {
  bungo.aspects.claude = {
    homeManager = {
      nixpkgs.config.allowUnfree = true;
      programs.claude-code = {
        enable = true;
      };

      xdg.mimeApps.defaultApplications."x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
    };
  };
}
