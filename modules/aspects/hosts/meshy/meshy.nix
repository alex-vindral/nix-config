{meshy, ...}: {
  den.aspects.meshy = {
    includes = [
      meshy.aspects.system
      meshy.aspects.nvidia
      meshy.aspects.wayland-gpu
      meshy.aspects.sops
    ];

    nixos = {pkgs, ...}: {
      programs.nix-ld.enable = true;

      nixpkgs.config.allowUnfree = true;
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        systemd-boot.configurationLimit = 10;
      };

      networking.networkmanager.enable = true;
      networking.networkmanager.wifi.powersave = false;
      users.users.bungo.extraGroups = ["networkmanager"];

      # Intel WiFi firmware + module.
      hardware.firmware = [pkgs.linux-firmware];
      boot.kernelModules = ["iwlwifi"];

      time.timeZone = "Europe/Stockholm";
      console = {
        font = "Lat2-Terminus16";
        keyMap = "sv-latin1";
      };
    };
  };
}
