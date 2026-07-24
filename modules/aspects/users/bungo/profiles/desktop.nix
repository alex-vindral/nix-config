{bungo, ...}: {
  # Graphical session and apps
  bungo.aspects.profiles.desktop = {
    includes = with bungo.aspects; [
      audio
      bluetooth
      dolphin
      easyeffects
      freerdp
      i3
      krita
      ladybird
      logitech
      mpv
      orion
      printing
      solaar
      spotify
      desktopEnvironment.sway
      vivaldi
    ];
  };
}
