{...}: {
  bungo.aspects.ssh = {
    homeManager = {
      programs.ssh = {
        enable = true;
        matchBlocks = {
          "composer-9" = {
            hostname = "10.10.50.81";
            user = "realsprint";
          };
        };
      };
    };

    provides.burken.nixos = {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };
    };
  };
}
