{...}: {
  # Reuses the existing claude-code OAuth (Pro/Max) for opencode's anthropic provider.
  # Run `opencode auth login` once and pick Anthropic → Claude Pro/Max.
  bungo.aspects.opencode = {
    homeManager = {
      nixpkgs.config.allowUnfree = true;
      programs.opencode = {
        enable = true;
        settings = {
          model = "anthropic/claude-sonnet-4-6";
          autoupdate = false;
        };
      };
    };
  };
}
