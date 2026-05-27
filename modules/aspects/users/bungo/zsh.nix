{den, ...}: {
  bungo.aspects.zsh = {
    includes = [
      (den.batteries.user-shell "zsh") # This enables it in HM and does host level set up
    ];

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        nerd-fonts.meslo-lg
      ];

      programs = {
        zsh = {
          autocd = true;
          defaultKeymap = "emacs";
        };
        starship = {
          enable = true;
        };
      };
    };
  };
}
