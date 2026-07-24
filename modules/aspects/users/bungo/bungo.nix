{bungo, ...}: {
  den.aspects.bungo = {host, ...}: let
    # What bungo uses each machine for (a user choice, keyed on host name).
    usageByHost = with bungo.aspects; {
      burken = [
        profiles.desktop
        profiles.work
        peripherals.airpods
        wireguard
      ];
      meshy = [
        profiles.desktop
        profiles.gaming
        peripherals.airpods
        peripherals.xbox
        wireguard
      ];
      wsl = [
        profiles.work
      ];
    };
  in {
    includes = [bungo.aspects.profiles.core] ++ (usageByHost.${host.name} or []);
  };
}
