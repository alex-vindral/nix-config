{bungo, ...}: {
  bungo.aspects.teams = {
    includes = [
      bungo.aspects.screensharing
    ];

    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.teams-for-linux];
    };
  };
}
