{bungo, ...}: {
  # Graphical / hardware / secret-dependent aspects.
  # Opt-in per host via `bungo.nix`. Don't include on tty-only hosts.
  bungo.aspects.desktop = {
    includes = [
      # bungo.aspects.kanata
      bungo.aspects.audio
      bungo.aspects.avahi
      bungo.aspects.awscli
      bungo.aspects.bluetooth
      bungo.aspects.easyeffects
      bungo.aspects.i3
      bungo.aspects.krita
      bungo.aspects.logitech
      bungo.aspects.mpv
      bungo.aspects.remmina
      bungo.aspects.s3
      bungo.aspects.slack
      bungo.aspects.solaar
      bungo.aspects.sops
      bungo.aspects.spotify
      bungo.aspects.sway
      bungo.aspects.teams
      bungo.aspects.vivaldi
      bungo.aspects.vm
      bungo.aspects.wireguard
    ];
  };
}
