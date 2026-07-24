{
  den,
  bungo,
  ...
}: {
  bungo.aspects.profiles.core = {
    includes = with bungo.aspects; [
      den.batteries.primary-user # For wheel

      atuin
      btop
      claude
      direnv
      dua
      eza
      gh
      ghostty
      git
      nh
      nvim
      opencode
      ssh
      tealdeer
      unzip
      yazi
      zoxide
      zsh
    ];

    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.tree];

      xdg.userDirs = {
        enable = true;
        createDirectories = true;
      };

      home.shellAliases = {
        "-" = "cd -";
        ".." = "cd ..";
      };
    };
  };
}
