{...}: {
  bungo.aspects.docker = {
    nixos = {
      virtualisation.docker.enable = true;
      users.users.bungo.extraGroups = ["docker"];

      networking.firewall.extraCommands = ''
        iptables -I nixos-fw -s 172.28.0.0/16 -j nixos-fw-accept
      '';

      # networking.firewall.extraInputRules = ''
      #   ip saddr 172.28.0.0/16 accept
      # '';
    };
  };
}
