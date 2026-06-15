{...}: {
  bungo.aspects.docker = {
    nixos = {
      virtualisation.docker.enable = true;
      users.users.bungo.extraGroups = ["docker"];
      hardware.nvidia-container-toolkit.enable = true;

      networking.firewall.extraCommands = ''
        iptables -I nixos-fw -s 172.28.0.0/16 -j nixos-fw-accept
      '';

      # networking.firewall.extraInputRules = ''
      #   ip saddr 172.28.0.0/16 accept
      # '';
    };

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
          ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/cat ${config.sops.secrets."docker/ghcr_token".path} | ${pkgs.docker}/bin/docker login ghcr.io -u x-access-token --password-stdin'";
        };
        Install.WantedBy = ["default.target"];
      };
    };
  };
}
