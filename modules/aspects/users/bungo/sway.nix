{den, ...}: {
  bungo.aspects.sway = {
    includes = [
      den.aspects.desktopEnvironment.ly
    ];

    homeManager = {pkgs, ...}: {
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
          };

          window = {
            border = 2;
            titlebar = true;
          };

          startup = [
            {
              command = "swayidle -w timeout 600 'swaylock -f' before-sleep 'swaylock -f'";
            }
          ];

          keybindings = {
            "${modifier}+Return" = "exec ghostty";
            "${modifier}+d" = "exec rofi -show drun";
            "${modifier}+f" = "fullscreen toggle";
            "${modifier}+q" = "kill";
            "${modifier}+Escape" = "exec swaylock";

            "${modifier}+Shift+s" = ''exec grim -g "$(slurp)" - | wl-copy'';

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
        };
      };

      programs.rofi = {
        enable = true;
        package = pkgs.rofi;
      };
    };

    nixos = {
      lib,
      pkgs,
      ...
    }: {
      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        # WLR_DRM_DEVICES must be a literal /dev/dri/cardN path -- wlroots/mesa
        # break on symlinks (e.g. /dev/dri/intel) and on paths containing `:`
        # (the env var is colon-separated). cardN numbering shuffles across
        # boots, so we resolve the udev-managed /dev/dri/intel symlink to its
        # current target here, in the sway wrapper, before exec'ing sway.
        extraSessionCommands = ''
          if [ -e /dev/dri/intel ]; then
            export WLR_DRM_DEVICES="$(${pkgs.coreutils}/bin/readlink -f /dev/dri/intel)"
          fi
        '';
      };

      environment.sessionVariables = {
        SWAY_UNSUPPORTED_GPU = "1";
        # Default EGL/GLX/Vulkan to Mesa so wlroots doesn't open nvidia nodes
        # during vendor enumeration. Per-app nvidia offload still works by
        # overriding these (see `nvidia-offload` wrapper).
        __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json";
        __GLX_VENDOR_LIBRARY_NAME = "mesa";
        VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
      };

      # mkForce so the sway aspect wins over i3's mkDefault when both are
      # enabled on a host (e.g. burken). You can still pick i3 at the ly
      # login screen; this only sets the preselected default.
      services.displayManager.defaultSession = lib.mkForce "sway";

      environment.systemPackages = with pkgs; [
        swaylock
        swayidle
        grim
        slurp
        wl-clipboard
        rofi
        i3status
      ];
    };
  };
}
