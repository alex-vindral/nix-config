{...}: {
  bungo.aspects.teams = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.teams-for-linux];
    };
  };
}
