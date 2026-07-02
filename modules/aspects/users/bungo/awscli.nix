{...}: {
  bungo.aspects.awscli = {
    homeManager = {
      config,
      pkgs,
      ...
    }: {
      home.packages = [pkgs.awscli2];

      sops.secrets."aws/composer/access_key_id" = {};
      sops.secrets."aws/composer/secret_access_key" = {};

      sops.templates."aws-composer-credentials.json".content = builtins.toJSON {
        Version = 1;
        AccessKeyId = config.sops.placeholder."aws/composer/access_key_id";
        SecretAccessKey = config.sops.placeholder."aws/composer/secret_access_key";
      };

      programs.awscli = {
        enable = true;
        settings."default" = {
          region = "us-east-1";
          output = "json";
        };
        credentials = {
          "default".credential_process =
            "${pkgs.coreutils}/bin/cat ${config.sops.templates."aws-composer-credentials.json".path}";
          "AutotestComposer".credential_process =
            "${pkgs.coreutils}/bin/cat ${config.sops.templates."aws-composer-credentials.json".path}";
        };
      };
    };
  };
}
