{...}: {
  bungo.aspects.docker-desktop = {
    nixos = {pkgs, ...}: {
      wsl.docker-desktop.enable = true;

      # Docker Desktop's integration bootstrap shells out to coreutils tools as
      # root to install and run its proxy binary; the upstream module only shims
      # a few into /bin, so add the rest it needs.
      wsl.extraBin = map (n: {src = "${pkgs.coreutils}/bin/${n}";}) [
        "install"
        "mv"
        "mkdir"
        "rm"
        "chmod"
        "chown"
        "cp"
        "ln"
        "ls"
        "readlink"
        "sleep"
      ];
    };
  };
}
