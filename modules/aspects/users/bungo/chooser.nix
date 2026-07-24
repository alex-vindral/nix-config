{...}: {
  # Output/region picker for the wlroots screencast portal.
  bungo.aspects.chooser = {
    nixos = {
      config,
      lib,
      pkgs,
      ...
    }:
      lib.mkIf config.programs.sway.enable {
        xdg.portal.wlr.settings.screencast = {
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
        };
      };
  };
}
