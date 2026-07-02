{den, ...}: {
  bungo.aspects.zsh = {
    includes = [
      (den.batteries.user-shell "zsh") # This enables it in HM and does host level set up
    ];

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        nerd-fonts.meslo-lg
      ];

      programs = {
        zsh = {
          autocd = true;
          defaultKeymap = "emacs";
          initContent = ''
            setopt AUTO_PUSHD        # cd pushes the old dir onto the stack
            setopt PUSHD_IGNORE_DUPS # don't keep duplicate dirs on the stack
            setopt PUSHD_SILENT      # don't print the stack after pushd/popd
            setopt PUSHD_MINUS       # make `cd -N` count back from the top (cd -2 = 2 dirs ago)

            bindkey '^[[1;5C' forward-word   # ctrl+right -> jump forward a word
            bindkey '^[[1;5D' backward-word  # ctrl+left  -> jump backward a word
          '';
        };
        starship = {
          enable = true;
        };
      };
    };
  };
}
