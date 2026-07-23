{...}: {
  bungo.aspects.rdp.homeManager = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options.rdpMachines = lib.mkOption {
      default = {};
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
        options = {
          key = lib.mkOption {type = lib.types.str;};
          label = lib.mkOption {
            type = lib.types.str;
            default = name;
          };
          host = lib.mkOption {type = lib.types.str;};
          user = lib.mkOption {type = lib.types.str;};
          secret = lib.mkOption {
            type = lib.types.str;
            default = "rdp/${name}";
          };
        };
      }));
    };

    config.rdpMachines = {
      composer-1.key = "j";
      composer-8.key = "k";
      composer-5.key = "l";
      threadripper.key = "t";
    };

    config.wayland.windowManager.sway.config = let
      machines = lib.attrValues config.rdpMachines;
      # Doubles as the status-bar hint while the leader is active.
      rdpMode =
        "rdp  "
        + lib.concatMapStringsSep "  " (m: "[${m.key}]${m.label}") machines
        + "  [Esc]cancel";
      rdpScript = pkgs.writeShellScript "rdp-connect" ''
        host="$1"; user="$2"; secret="$3"
        exec ${pkgs.freerdp}/bin/xfreerdp \
          /v:"$host" /u:"$user" /p:"$(cat "$secret")" \
          /gfx:progressive /network:lan /size:3840x2160 \
          -wallpaper -themes -window-drag -menu-anims +clipboard /cert:ignore /sound
      '';
      rdpConnect = m: ''exec ${rdpScript} ${m.host} ${m.user} ${config.sops.secrets.${m.secret}.path} ; mode "default"'';
    in {
      keybindings."Mod4+r" = ''mode "${rdpMode}"'';
      modes.${rdpMode} =
        lib.listToAttrs (map (m: lib.nameValuePair m.key (rdpConnect m)) machines)
        // {
          "Escape" = ''mode "default"'';
          "Return" = ''mode "default"'';
        };
    };
  };
}
