{
  den,
  bungo,
  lib,
  ...
}: {
  # Parametric on host so the desktop bundle only resolves on graphical
  # hosts. Anything in the unconditional `includes` list runs on every
  # host this user lives on (burken, wsl, future).
  den.aspects.bungo = {host, ...}: {
    includes =
      [
        den.batteries.primary-user # For wheel

        # Core — every host
        bungo.aspects.atuin
        bungo.aspects.btop
        bungo.aspects.claude
        bungo.aspects.direnv
        bungo.aspects.dua
        bungo.aspects.eza
        bungo.aspects.gh
        bungo.aspects.ghostty
        bungo.aspects.git
        bungo.aspects.nh
        bungo.aspects.nvim
        bungo.aspects.opencode
        bungo.aspects.slk
        bungo.aspects.ssh
        bungo.aspects.tealdeer
        bungo.aspects.unzip
        bungo.aspects.yazi
        bungo.aspects.zoxide
        bungo.aspects.zsh
      ]
      # Graphical / hardware / secret-dependent — only on hosts that want it.
      # Add another host name here when a new graphical host comes online.
      ++ lib.optionals (host.name == "burken") [
        bungo.aspects.desktop
      ]
      ++ lib.optionals (builtins.elem host.name ["burken" "wsl"]) [
        bungo.aspects.docker
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
