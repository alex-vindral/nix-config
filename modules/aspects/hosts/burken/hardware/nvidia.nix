{...}: {
  burken.aspects.nvidia = {
    nixos = {config, ...}: {
      # NVIDIA RTX 5080 (Blackwell)
      services.xserver.videoDrivers = ["nvidia"];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;

        # Blackwell (RTX 50-series) only supports the open kernel module.
        open = true;

        nvidiaSettings = true;

        package = config.boot.kernelPackages.nvidiaPackages.latest;
      };
    };
  };
}
