{...}: {
  bungo.aspects.awscli = {
    homeManager = {
      config,
      pkgs,
      ...
    }: {
      home.packages = [pkgs.awscli2];

      sops.secrets."aws/composer_credentials" = {};

      programs.awscli = {
        enable = true;
        settings."default" = {
          region = "us-east-1";
          output = "json";
        };
        credentials = {
          "default".credential_process =
            "${pkgs.coreutils}/bin/cat ${config.sops.secrets."aws/composer_credentials".path}";
          "AutotestComposer".credential_process =
            "${pkgs.coreutils}/bin/cat ${config.sops.secrets."aws/composer_credentials".path}";
        };
      };
    };
  };
}
