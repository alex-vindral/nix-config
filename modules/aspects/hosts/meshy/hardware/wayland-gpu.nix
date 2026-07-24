{...}: {
  # nvidia is meshy's sole GPU; wlroots treats it as unsupported, so allow it.
  meshy.aspects.wayland-gpu = {
    nixos.environment.sessionVariables = {
      SWAY_UNSUPPORTED_GPU = "1";
    };
  };
}
