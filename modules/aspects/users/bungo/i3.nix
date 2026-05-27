{den, ...}: {
  bungo.aspects.i3 = {
    includes = [
      den.aspects.desktopEnvironment.ly
    ];

    homeManager = {
      xsession.windowManager.i3 = {
        enable = true;
        config = {
          window = {
            border = 2;
            titlebar = true;
            commands = [
              {
                command = "border normal 2";
                criteria = {class = ".*";};
              }
            ];
          };
          modifier = "Mod4";
          focus.followMouse = false;
          startup = [
            {
              command = "xset s off -dpms s noblank";
              notification = false;
            }
          ];
          keybindings = {
            "Mod4+Return" = "exec --no-startup-id ghostty";
            "Mod4+d" = "exec --no-startup-id dmenu_run";
            "Mod4+f" = "fullscreen toggle";
            "Mod4+q" = "kill";
            "Mod4+Escape" = "exec --no-startup-id i3lock-fancy-rapid 10 5";

            "Mod4+Shift+s" = "exec --no-startup-id flameshot gui";

            "Mod4+Shift+e" = "exec --no-startup-id i3-msg exit";
            "Mod4+Shift+r" = "reload";

            "Mod4+h" = "focus left";
            "Mod4+j" = "focus down";
            "Mod4+k" = "focus up";
            "Mod4+l" = "focus right";

            "Mod4+Shift+h" = "move left";
            "Mod4+Shift+j" = "move down";
            "Mod4+Shift+k" = "move up";
            "Mod4+Shift+l" = "move right";

            "Mod4+1" = "workspace number 1";
            "Mod4+2" = "workspace number 2";
            "Mod4+3" = "workspace number 3";
            "Mod4+4" = "workspace number 4";
            "Mod4+5" = "workspace number 5";
            "Mod4+6" = "workspace number 6";
            "Mod4+7" = "workspace number 7";
            "Mod4+8" = "workspace number 8";
            "Mod4+9" = "workspace number 9";
            "Mod4+0" = "workspace number 10";

            "Mod4+Shift+1" = "move container to workspace number 1";
            "Mod4+Shift+2" = "move container to workspace number 2";
            "Mod4+Shift+3" = "move container to workspace number 3";
            "Mod4+Shift+4" = "move container to workspace number 4";
            "Mod4+Shift+5" = "move container to workspace number 5";
            "Mod4+Shift+6" = "move container to workspace number 6";
            "Mod4+Shift+7" = "move container to workspace number 7";
            "Mod4+Shift+8" = "move container to workspace number 8";
            "Mod4+Shift+9" = "move container to workspace number 9";
            "Mod4+Shift+0" = "move container to workspace number 10";
          };
        };
      };
    };

    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: let
      nvidiaDrivesDisplay =
        builtins.elem "nvidia" config.services.xserver.videoDrivers
        && !config.hardware.nvidia.prime.offload.enable;
    in {
      services.xserver = {
        enable = true;
        xkb = {
          layout = lib.mkDefault "se";
          variant = lib.mkDefault "nodeadkeys";
        };
        desktopManager.xterm.enable = false;
        displayManager.startx = {
          enable = true;
          generateScript = true;
        };
        windowManager.i3.enable = true;

        screenSection =
          if nvidiaDrivesDisplay
          then ''
            Option "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
            Option "AllowIndirectGLXProtocol" "off"
            Option "TripleBuffer" "on"
          ''
          else ''
            Option "TearFree" "true"
          '';
      };

      services.displayManager.defaultSession = lib.mkDefault "none+i3";

      environment.systemPackages = with pkgs; [
        dmenu
        i3lock-fancy-rapid
        i3status
        flameshot
        xclip
      ];
    };
  };
}
