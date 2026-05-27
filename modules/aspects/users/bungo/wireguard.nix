{inputs, ...}: {
  bungo.aspects.wireguard = {
    nixos = {config, ...}: {
      sops.secrets."wireguard/vindral/private_key" = {
        sopsFile = "${inputs.nix-secrets}/secrets/bungo.yaml";
      };

      networking.wg-quick.interfaces.vindral = {
        address = ["192.168.2.35/32"];
        privateKeyFile = config.sops.secrets."wireguard/vindral/private_key".path;
        autostart = false;

        peers = [
          {
            publicKey = "kieAaMhj/2JG0eOhvt9G7t2MA97HsH7Qc5+mOcgbfyM=";
            allowedIPs = ["0.0.0.0/0"];
            endpoint = "31.12.82.82:7871";
          }
        ];
      };
    };

    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.wireguard-tools];
    };
  };
}
