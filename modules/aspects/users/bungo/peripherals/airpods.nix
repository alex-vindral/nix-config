{bungo, ...}: {
  bungo.aspects.peripherals.airpods = {
    includes = [
      bungo.aspects.bluetooth
    ];

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        librepods
      ];
    };
  };
}
