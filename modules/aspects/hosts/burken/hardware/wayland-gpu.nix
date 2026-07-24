{...}: {
  # Force wlroots onto the Intel iGPU; nvidia is offload-only.
  burken.aspects.wayland-gpu = {
    nixos = {pkgs, ...}: {
      # WLR_DRM_DEVICES needs a literal cardN path (breaks on symlinks / `:`),
      # so resolve igpu.nix's /dev/dri/intel symlink at session start.
      programs.sway.extraSessionCommands = ''
        if [ -e /dev/dri/intel ]; then
          export WLR_DRM_DEVICES="$(${pkgs.coreutils}/bin/readlink -f /dev/dri/intel)"
        fi
      '';

      environment.sessionVariables = {
        SWAY_UNSUPPORTED_GPU = "1"; # nvidia present; wlroots aborts otherwise

        # Default EGL/GLX/Vulkan to Mesa (per-app offload overrides these).
        __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json";
        __GLX_VENDOR_LIBRARY_NAME = "mesa";
        VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
      };
    };
  };
}
