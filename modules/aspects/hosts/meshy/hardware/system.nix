{...}: {
  meshy.aspects.system = {
    nixos = {pkgs, ...}: {
      # Generated hardware configuration
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [];
      boot.kernelModules = ["kvm-amd"];
      boot.extraModulePackages = [];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/0c3874f4-6940-44a6-835b-fa77856b8eb7";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/CE2E-696A";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };

      swapDevices = [];

      nixpkgs.hostPlatform = "x86_64-linux";

      # CPU
      hardware.cpu.amd.updateMicrocode = true;

      hardware.enableRedistributableFirmware = true;

      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}
