{...}: {
  burken.aspects.system = {
    nixos = {pkgs, ...}: {
      # Generated hardware configuration
      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [];
      boot.kernelModules = ["kvm-intel"];
      boot.extraModulePackages = [];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/07a00a0f-b703-4378-a7e0-19c43f102b26";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/02D8-0671";
        fsType = "vfat";
        options = ["umask=0077"];
      };

      swapDevices = [
        {device = "/dev/disk/by-uuid/beaee378-e0ee-46d2-8d91-0c56591a5539";}
      ];

      nixpkgs.hostPlatform = "x86_64-linux";

      # CPU
      hardware.cpu.intel.npu.enable = true;
      hardware.cpu.intel.updateMicrocode = true;

      hardware.enableRedistributableFirmware = true;

      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}
