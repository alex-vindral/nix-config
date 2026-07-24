{bungo, ...}: {
  bungo.aspects.peripherals.xbox = {
    includes = [
      bungo.aspects.bluetooth
    ];

    nixos = {
      # Xbox controller support: provides the xpadneo driver and, crucially,
      # disables Bluetooth ERTM (Enhanced Re-Transmission Mode), which Xbox
      # One/Series controllers refuse to pair with when enabled.
      hardware.xpadneo.enable = true;
    };
  };
}
