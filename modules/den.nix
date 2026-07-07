{
  inputs,
  lib,
  den,
  ...
}: {
  # Namespaces: `eg` (example), `bungo` for user-specific aspects,
  # `burken` and `wsl` for host-specific aspects.
  imports = [
    (inputs.den.namespace "eg" true)
    (inputs.den.namespace "bungo" true)
    (inputs.den.namespace "burken" true)
    (inputs.den.namespace "wsl" true)
  ];

  # Enables den's angle-bracket syntax in modules.
  _module.args.__findFile = den.lib.__findFile;

  # Hosts and homes
  den.hosts.x86_64-linux.burken.users.bungo = {};
  den.hosts.x86_64-linux.wsl = {
    wsl.enable = true; # provided by den.batteries' wsl-host-aspect
    users.bungo = {};
  };
  den.homes.x86_64-linux.bungo = {};

  # enable hm for all users
  den.schema.user.classes = lib.mkDefault ["homeManager"];

  den.schema.user.includes = [
    den.batteries.mutual-provider
    {
      homeManager.nixpkgs.overlays = [inputs.self.overlays.default];
    }
  ];

  den.schema.host.includes = [
    {
      nixos.nixpkgs.overlays = [inputs.self.overlays.default];
    }
  ];
}
