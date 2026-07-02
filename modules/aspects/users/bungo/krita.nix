{...}: {
  bungo.aspects.krita = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        krita
      ];
    };
  };
}
