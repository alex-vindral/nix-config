{...}: {
  bungo.aspects.ghostty = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        nerd-fonts.meslo-lg
      ];

      programs.ghostty = {
        enable = true;
        settings = {
          shell-integration-features = "cursor,sudo,title,ssh-env,ssh-terminfo"; # For proper ssh support
          theme = "Kanagawa Wave";
          font-family = "MesloLGS Nerd Font";
          background-opacity = 0.98;
          resize-overlay = "never";
          app-notifications = "no-clipboard-copy";
          window-decoration = "none";
          keybind = [
            "ctrl++=unbind"
            "ctrl+?=increase_font_size:1"
          ];
        };
      };
    };
  };
}
