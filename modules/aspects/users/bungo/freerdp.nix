{...}: {
  bungo.aspects.freerdp = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.freerdp];
    };
  };
}
