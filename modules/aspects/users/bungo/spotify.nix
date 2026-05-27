{...}: {
  bungo.aspects.spotify = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        # spotify-qt
        # librespot
        spotify
      ];
    };
  };
}
