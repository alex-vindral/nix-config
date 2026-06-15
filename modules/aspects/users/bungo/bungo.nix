{
  den,
  bungo,
  ...
}: {
  den.aspects.bungo = {
    includes = [
      den.batteries.primary-user # For wheel

      # bungo.aspects.kanata
      bungo.aspects.spotify
      bungo.aspects.audio
      bungo.aspects.bluetooth
      bungo.aspects.claude
      bungo.aspects.direnv
      bungo.aspects.docker
      bungo.aspects.dua
      bungo.aspects.easyeffects
      bungo.aspects.eza
      bungo.aspects.ghostty
      bungo.aspects.git
      bungo.aspects.i3
      bungo.aspects.logitech
      bungo.aspects.nh
      bungo.aspects.nvim
      bungo.aspects.opencode
      bungo.aspects.remmina
      bungo.aspects.s3
      bungo.aspects.slack
      bungo.aspects.slk
      bungo.aspects.sops
      bungo.aspects.ssh
      bungo.aspects.sway
      bungo.aspects.tealdeer
      bungo.aspects.teams
      bungo.aspects.unzip
      bungo.aspects.vivaldi
      bungo.aspects.vm
      bungo.aspects.yazi
      bungo.aspects.zoxide
      bungo.aspects.zsh
    ];

    nixos = {pkgs, ...}: {
      users.users.bungo.packages = with pkgs; [
        tree
        btop
      ];
    };

    homeManager = {
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
