{...}: {
  bungo.aspects.btop = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.btop];
    };
  };
}
