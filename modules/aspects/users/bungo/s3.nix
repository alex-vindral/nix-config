{...}: {
  bungo.aspects.s3 = {
    homeManager = {
      config,
      pkgs,
      ...
    }: {
      home.packages = [pkgs.rclone pkgs.pull];

      sops.secrets."aws/composer/access_key_id" = {};
      sops.secrets."aws/composer/secret_access_key" = {};

      sops.templates."rclone.conf".content = ''
        [composer]
        type = s3
        provider = AWS
        access_key_id = ${config.sops.placeholder."aws/composer/access_key_id"}
        secret_access_key = ${config.sops.placeholder."aws/composer/secret_access_key"}
        region = eu-north-1
        use_dual_stack = true
      '';

      systemd.user.services.rclone-s3 = {
        Unit = {
          Description = "rclone mount composer:composer-storage at ~/s3";
          After = ["sops-nix.service"];
          Requires = ["sops-nix.service"];
        };
        Service = {
          Type = "notify";
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/s3";
          ExecStart = "${pkgs.rclone}/bin/rclone --config ${config.sops.templates."rclone.conf".path} mount composer:composer-storage %h/s3 --vfs-cache-mode writes --dir-cache-time 1h --rc --rc-no-auth";
          ExecStop = "/run/wrappers/bin/fusermount -uz %h/s3";
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install.WantedBy = ["default.target"];
      };
    };
  };
}
