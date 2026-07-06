{...}: {
  bungo.aspects.ghostty = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        nerd-fonts.meslo-lg
      ];

      programs.ghostty = {
        enable = true;
        settings = {
          app-notifications = "no-clipboard-copy";
          background-opacity = 0.98;
          clipboard-read = "allow";
          clipboard-write = "allow";
          custom-shader = ["${./cursor_focus.glsl}" "${./cursor_tail_glow.glsl}"];
          font-family = "MesloLGS Nerd Font";
          keybind = ["ctrl++=unbind" "ctrl+.=increase_font_size:1"];
          resize-overlay = "never";
          shell-integration-features = "cursor,sudo,title,ssh-env,ssh-terminfo"; # For proper ssh support
          theme = "Kanagawa Wave";
          window-decoration = "none";
        };
      };
    };
  };
}
