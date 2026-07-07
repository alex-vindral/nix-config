{...}: {
  # WSL host. Activated by `den.hosts.x86_64-linux.wsl.wsl.enable = true`
  # in modules/den.nix — the wsl-host-aspect battery loads NixOS-WSL.
  # This aspect only carries the small, tty-only non-WSL specifics.
  den.aspects.wsl = {
    nixos = {
      nixpkgs.config.allowUnfree = true;
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      time.timeZone = "Europe/Stockholm";
      console = {
        font = "Lat2-Terminus16";
        keyMap = "sv-latin1";
      };

      # Uncomment if a port on the WSL side isn't reachable from Windows and
      # opening individual ports via `networking.firewall.allowedTCPPorts`
      # isn't enough. Off by default — match burken.
      # networking.firewall.enable = false;
    };
  };
}
