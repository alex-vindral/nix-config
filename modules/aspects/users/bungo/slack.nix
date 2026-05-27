{...}: {
  bungo.aspects.slack = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.slack];
    };
  };
}
