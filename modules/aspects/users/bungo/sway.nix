{den, ...}: {
  bungo.aspects.sway = {
    includes = [
      den.aspects.desktopEnvironment.ly
    ];

    homeManager = {pkgs, ...}: let
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

      programs.rofi = {
        enable = true;
        package = pkgs.rofi;
      };

      systemd.user.services.wl-clip-persist = {
        Unit = {
          Description = "Persist Wayland clipboard after source app exits";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };
        Install.WantedBy = ["graphical-session.target"];
        Service = {
          ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular";
          Restart = "on-failure";
        };
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

      # Screen sharing for Electron/web apps (teams-for-linux, etc.) on
      # wlroots. The NixOS sway module already enables xdg.portal with gtk as
      # the default backend; we only add the wlr ScreenCast backend and point
      # ScreenCast at it. PipeWire is enabled via the audio aspect.
      #
      # wlr needs a chooser to pick the output/region. The NixOS module starts
      # the portal with an explicit `--config`, so the per-user
      # ~/.config/xdg-desktop-portal-wlr/config is ignored -- the chooser MUST
      # be set here via wlr.settings. Without it the portal probes
      # wofi/rofi/etc on a restricted PATH, finds nothing, and dies with
      # "no output found". slurp (absolute store path) handles selection.
      xdg.portal = {
        wlr.enable = true;
        wlr.settings.screencast = {
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
        };
        config.sway."org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
      };

      environment.systemPackages = with pkgs; [
        swaylock-effects
        swayidle
        grim
        slurp
        satty # annotation editor for screenshots (flameshot-like)
        wl-screenrec # VA-API hw-accelerated region screen recording
        jq # window/output geometry queries for grim -g
        wl-clipboard
        rofi
        i3status
      ];
    };
  };
}
