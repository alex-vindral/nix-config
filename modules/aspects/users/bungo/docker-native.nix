{...}: {
  bungo.aspects.docker-native = {
    nixos = {
      virtualisation.docker.enable = true;
      users.users.bungo.extraGroups = ["docker"];
      hardware.nvidia-container-toolkit.enable = true;

      networking.firewall.extraCommands = ''
        iptables -I nixos-fw -s 172.28.0.0/16 -j nixos-fw-accept
      '';
    };
  };
}
