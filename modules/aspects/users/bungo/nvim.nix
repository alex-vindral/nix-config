{inputs, ...}: {
  flake-file.inputs = {
    nix-nvim = {
      url = "github:buungoo/nix-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  bungo.aspects.nvim = {
    homeManager = {pkgs, ...}: {
      nixpkgs.config.allowUnfree = true;
      home.packages = [inputs.nix-nvim.packages.${pkgs.system}.nvim];

      home.shellAliases = {
        "nivm" = "nvim";
        "vi" = "nvim";
        "vim" = "nvim";
      };

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        MANPAGER = "nvim +Man!";
      };

      programs.git.settings.core.editor = "nvim";
    };
  };
}
