{...}: {
  burken.aspects.igpu = {
    nixos = {pkgs, ...}: {
      # Intel iGPU (Core Ultra, Xe / Xe2 graphics)
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vpl-gpu-rt
          libvdpau-va-gl
        ];
        extraPackages32 = with pkgs.pkgsi686Linux; [
          intel-media-driver
        ];
      };

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";
      };

      environment.systemPackages = with pkgs; [
        libva-utils
        intel-gpu-tools
        mesa-demos
      ];
    };
  };
}
