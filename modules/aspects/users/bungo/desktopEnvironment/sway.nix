{
  den,
  bungo,
  ...
}: {
  # Complete sway desktop environment: the WM plus session scaffolding
  # (display manager, launcher, lock/idle + screenshot/clipboard tooling).
  bungo.aspects.desktopEnvironment.sway = {
    includes = [
      bungo.aspects.sway # the window manager
      den.aspects.desktopEnvironment.ly # display manager
    ];

    homeManager = {pkgs, ...}: {
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
      # mkForce so sway wins over i3's mkDefault when both are enabled on a host
      # (e.g. burken). You can still pick i3 at the ly login screen.
      services.displayManager.defaultSession = lib.mkForce "sway";

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
