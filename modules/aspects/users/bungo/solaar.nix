# solaar config "PRO X 2 LIGHTSPEED"
# solaar config "PRO X 2 LIGHTSPEED" headset-mic-snr on
# solaar config "PRO X 2 LIGHTSPEED" headset-onboard-eq <0 index to 4> <change in db>
{inputs, ...}: {
  flake-file.inputs = {
    solaar = {
      url = "github:Svenum/Solaar-Flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  bungo.aspects.solaar = {
    nixos = {
      imports = [inputs.solaar.nixosModules.default];
      services.solaar.enable = true;
    };
  };
}
