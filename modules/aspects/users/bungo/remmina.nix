# TODO: Remove
{...}: {
  bungo.aspects.remmina = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.remmina];
    };
  };
}
