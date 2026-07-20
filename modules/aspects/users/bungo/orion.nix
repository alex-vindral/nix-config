{inputs, ...}: {
  flake-file.inputs = {
    orion-browser = {
      url = "github:dokokitsune/orion-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  bungo.aspects.orion = {
    # Wrapper flatpak-installs Orion on first launch; needs the daemon/portals.
    nixos = {
      services.flatpak.enable = true;
    };

    homeManager = {pkgs, ...}: {
      home.packages = [inputs.orion-browser.packages.${pkgs.system}.default];
    };
  };
}
