{bungo, ...}: {
  bungo.aspects.docker = {host, ...}: {
    includes = [
      (
        if (host.wsl or {}).enable or false
        then bungo.aspects.docker-desktop
        else bungo.aspects.docker-native
      )
    ];

    # TODO: needs bungo.aspects.sops; re-enable once WSL can decrypt secrets.
    # homeManager = {
    #   config,
    #   pkgs,
    #   ...
    # }: {
    #   sops.secrets."docker/ghcr_token" = {};
    #
    #   systemd.user.services.ghcr-login = {
    #     Unit = {
    #       Description = "Log Docker in to ghcr.io using the ghcr token";
    #       After = ["sops-nix.service"];
    #       Requires = ["sops-nix.service"];
    #     };
    #     Service = {
    #       Type = "oneshot";
    #       ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/cat ${config.sops.secrets."docker/ghcr_token".path} | ${pkgs.docker}/bin/docker login ghcr.io -u x-access-token --password-stdin'";
    #     };
    #     Install.WantedBy = ["default.target"];
    #   };
    # };
  };
}
