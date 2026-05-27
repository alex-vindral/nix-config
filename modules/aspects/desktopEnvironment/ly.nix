{den, ...}: {
  den.aspects.desktopEnvironment.ly = {
    nixos = {
      services.displayManager.ly = {
        enable = true;
      };
    };
  };
}
