{...}: {
  bungo.aspects.ladybird = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        ladybird
      ];
    };
  };
}
