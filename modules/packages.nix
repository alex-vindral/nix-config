{inputs, ...}: {
  flake.overlays.default = final: _prev: {
    pull = final.callPackage ../packages/pull.nix {};
    headsetcontrol-gui = final.callPackage ../packages/headsetcontrol-gui.nix {};
  };

  perSystem = {pkgs, ...}: {
    packages.pull = pkgs.callPackage ../packages/pull.nix {};
    packages.headsetcontrol-gui = pkgs.callPackage ../packages/headsetcontrol-gui.nix {};
  };
}
