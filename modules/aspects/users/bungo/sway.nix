{...}: {
  bungo.aspects.sway = {
    homeManager = {...}: let
      # Doubles as the status-bar hint while the leader is active.
      screenshotMode = "screenshot  [r]egion  [w]indow  [o]utput  [d]record  [Esc]cancel";
      # swaylock-effects: screenshot the screen then blur it (i3lock-blur equivalent).
      lockCmd = "swaylock -f --screenshots --clock --indicator --effect-blur 7x5";
      #  --effect-vignette 0.5:0.5 --fade-in 0.2
    in {
      wayland.windowManager.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        config = rec {
          modifier = "Mod4";
          terminal = "ghostty";
          menu = "rofi -show drun";

          focus.followMouse = false;

          input."*" = {
            xkb_layout = "se";
            xkb_variant = "nodeadkeys";
            repeat_delay = "250";
            repeat_rate = "40";
          };

          window = {
            border = 2;
            titlebar = true;
          };

          startup = [
            {
              command = "swayidle -w timeout 600 '${lockCmd}' before-sleep '${lockCmd}'";
            }
          ];

          keybindings = {
            "${modifier}+Return" = "exec ghostty";
            "${modifier}+d" = "exec rofi -show drun";
            "${modifier}+f" = "fullscreen toggle";
            "${modifier}+q" = "kill";
            "${modifier}+Escape" = "exec ${lockCmd}";

            # Screenshot/record leader; capture keys live in `modes` below.
            "${modifier}+s" = ''mode "${screenshotMode}"'';

            "${modifier}+Shift+e" = "exit";
            "${modifier}+Shift+r" = "reload";

            "${modifier}+h" = "focus left";
            "${modifier}+j" = "focus down";
            "${modifier}+k" = "focus up";
            "${modifier}+l" = "focus right";

            "${modifier}+Shift+h" = "move left";
            "${modifier}+Shift+j" = "move down";
            "${modifier}+Shift+k" = "move up";
            "${modifier}+Shift+l" = "move right";

            "${modifier}+1" = "workspace number 1";
            "${modifier}+2" = "workspace number 2";
            "${modifier}+3" = "workspace number 3";
            "${modifier}+4" = "workspace number 4";
            "${modifier}+5" = "workspace number 5";
            "${modifier}+6" = "workspace number 6";
            "${modifier}+7" = "workspace number 7";
            "${modifier}+8" = "workspace number 8";
            "${modifier}+9" = "workspace number 9";
            "${modifier}+0" = "workspace number 10";

            "${modifier}+Shift+1" = "move container to workspace number 1";
            "${modifier}+Shift+2" = "move container to workspace number 2";
            "${modifier}+Shift+3" = "move container to workspace number 3";
            "${modifier}+Shift+4" = "move container to workspace number 4";
            "${modifier}+Shift+5" = "move container to workspace number 5";
            "${modifier}+Shift+6" = "move container to workspace number 6";
            "${modifier}+Shift+7" = "move container to workspace number 7";
            "${modifier}+Shift+8" = "move container to workspace number 8";
            "${modifier}+Shift+9" = "move container to workspace number 9";
            "${modifier}+Shift+0" = "move container to workspace number 10";
          };

          # Screenshot/record leader (enter via Mod+s). Each key captures then
          # returns to default. satty annotates + copies; recordings save to
          # ~/Videos and d toggles (second press SIGINTs wl-screenrec to finalize).
          modes.${screenshotMode} = {
            "r" = ''exec grim -g "$(slurp)" - | satty --filename - --copy-command wl-copy ; mode "default"'';
            "w" = ''exec grim -g "$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp)" - | satty --filename - --copy-command wl-copy ; mode "default"'';
            "o" = ''exec grim -g "$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')" - | satty --filename - --copy-command wl-copy ; mode "default"'';
            "d" = ''exec sh -c 'if pkill -INT wl-screenrec; then exit 0; fi; mkdir -p ~/Videos; wl-screenrec -g "$(slurp)" -f ~/Videos/recording-$(date +%s).mp4' ; mode "default"'';

            "Escape" = ''mode "default"'';
            "Return" = ''mode "default"'';
          };
        };
      };
    };

    nixos = {
      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
      };
    };
  };
}
