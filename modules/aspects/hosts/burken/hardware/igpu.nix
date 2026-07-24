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

      # Stable symlink for the iGPU DRM device (cardN shuffles across boots).
      # Consumed by WLR_DRM_DEVICES, which can't use by-path/* (wlroots splits
      # on `:`, PCI addresses contain colons).
      services.udev.extraRules = ''
        SUBSYSTEM=="drm", KERNEL=="card[0-9]*", ATTRS{vendor}=="0x8086", SYMLINK+="dri/intel"
      '';
    };
  };
}
