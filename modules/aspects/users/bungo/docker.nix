{bungo, lib, ...}: {
  bungo.aspects.docker = {host, ...}: let
    isWsl = (host.wsl or {}).enable or false;
  in {
    includes = [
      bungo.aspects.sops
      (
        if isWsl
        then bungo.aspects.docker-desktop
        else bungo.aspects.docker-native
      )
    ];

    homeManager = {
      config,
      pkgs,
      ...
    }: {
      sops.secrets."docker/ghcr_token" = {};

      systemd.user.services.ghcr-login = {
        Unit = {
          Description = "Log Docker in to ghcr.io using the ghcr token";
          After = ["sops-nix.service"];
          Requires = ["sops-nix.service"];
        };
        Service = {
          Type = "oneshot";
          # Docker Desktop's credsStore shells out to a Windows helper on the
          # interop PATH, which the service doesn't otherwise inherit.
          Environment = lib.optional isWsl ''"PATH=/mnt/c/Program Files/Docker/Docker/resources/bin"'';
          ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/cat ${config.sops.secrets."docker/ghcr_token".path} | ${pkgs.docker}/bin/docker login ghcr.io -u x-access-token --password-stdin'";
        };
        Install.WantedBy = ["default.target"];
      };
    };
  };
}
