{bungo, ...}: {
  bungo.aspects.profiles.work = {
    includes = with bungo.aspects; [
      avahi
      awscli
      docker
      rdp
      s3
      slack
      sops
      teams
      slk
      remmina
      vm
    ];
  };
}
