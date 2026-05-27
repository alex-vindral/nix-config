{...}: {
  bungo.aspects.bluetooth = {
    nixos = {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
    };

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        bluetui
        librepods
      ];
    };
  };
}
