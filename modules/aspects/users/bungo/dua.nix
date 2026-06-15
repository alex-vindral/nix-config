{...}: {
  bungo.aspects.dua = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        dua
      ];
    };
  };
}
