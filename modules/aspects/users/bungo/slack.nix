{...}: {
  bungo.aspects.slack = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.slack];

      xdg.mimeApps.defaultApplications."x-scheme-handler/slack" = "slack.desktop";
    };
  };
}
