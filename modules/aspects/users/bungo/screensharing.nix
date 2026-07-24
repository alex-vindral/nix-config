{bungo, ...}: {
  # Screen-sharing for apps that need it (e.g. teams). Wayland needs the
  # wlroots portal; X11 apps capture directly.
  bungo.aspects.screensharing = {
    includes = [bungo.aspects.chooser];

    nixos = {
      config,
      lib,
      ...
    }:
      lib.mkIf config.programs.sway.enable {
        xdg.portal = {
          wlr.enable = true;
          config.sway."org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
        };
      };
  };
}
