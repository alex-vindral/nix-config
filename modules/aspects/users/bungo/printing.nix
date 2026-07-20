{...}: {
  bungo.aspects.printing = {
    nixos = {
      services.printing.enable = true;
    };
  };
}
