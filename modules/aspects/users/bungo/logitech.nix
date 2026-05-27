{...}: {
  bungo.aspects.logitech = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        headsetcontrol
        headsetcontrol-gui
      ];
    };

    nixos = {pkgs, ...}: {
      services.udev.packages = [pkgs.headsetcontrol];
    };
  };
}
