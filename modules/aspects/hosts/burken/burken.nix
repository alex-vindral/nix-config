{burken, ...}: {
  den.aspects.burken = {
    includes = [
      burken.aspects.system
      burken.aspects.nvidia
      burken.aspects.igpu
      burken.aspects.vfio
      burken.aspects.sops
    ];

    nixos = {pkgs, ...}: {
      programs.nix-ld.enable = true;

      # iGPU drives the display; dGPU is used on demand via `nvidia-offload`.
      hardware.nvidia.prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:2:0:0";
      };

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
      users.users.bungo.extraGroups = ["networkmanager"];

      time.timeZone = "Europe/Stockholm";
      console = {
        font = "Lat2-Terminus16";
        keyMap = "sv-latin1";
      };
    };
  };
}
