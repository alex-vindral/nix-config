{...}: {
  bungo.aspects.slk = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.slk];
    };
  };
}
