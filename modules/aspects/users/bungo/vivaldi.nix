{inputs, ...}: {
  flake-file.inputs = {
    wl-app-fullscreen = {
      url = "github:w9n/wl-app-fullscreen";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  bungo.aspects.vivaldi = {
    nixos = {
      nixpkgs.config.allowUnfree = true;
    };

    homeManager = {pkgs, ...}: let
      # Wayland proxy that strips the FULLSCREEN state from
      # compositor-initiated xdg_toplevel.configure events (sway's mod+f).
      # The window still fills the screen, but Vivaldi never learns it is
      # "fullscreen", so it keeps its tab/address bar instead of entering
      # the F11-style chrome-hiding UI. App-initiated F11 still works.
      proxy = inputs.wl-app-fullscreen.packages.${pkgs.system}.default;

      # Re-exec Vivaldi under the proxy. symlinkJoin mirrors the original
      # package, then we replace the bin and patch the desktop entry so
      # launches from a terminal, rofi or sway all go through the proxy.
      vivaldi = pkgs.symlinkJoin {
        name = "vivaldi-wl-app-fullscreen";
        paths = [pkgs.vivaldi];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          rm $out/bin/vivaldi
          makeWrapper ${proxy}/bin/wl-app-fullscreen $out/bin/vivaldi \
            --add-flags "-- ${pkgs.vivaldi}/bin/vivaldi"

          for f in $out/share/applications/*.desktop; do
            [ -L "$f" ] || continue
            target=$(readlink -f "$f")
            rm "$f"
            sed "s#${pkgs.vivaldi}/bin/vivaldi#$out/bin/vivaldi#g" \
              "$target" > "$f"
          done
        '';
      };
    in {
      nixpkgs.config.allowUnfree = true;
      programs.vivaldi = {
        enable = true;
        package = vivaldi;
      };
    };
  };
}
