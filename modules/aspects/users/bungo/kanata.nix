{...}: {
  bungo.aspects.kanata = {
    nixos = {
      services.kanata = {
        enable = true;
        keyboards.internal = {
          # Leave devices empty to grab all detected keyboards. Pin to a
          # specific device with /dev/input/by-id/... if multiple keyboards
          # cause trouble.
          devices = [];

          extraDefCfg = "process-unmapped-keys yes";

          config = ''
            (defvar
              tap-time 200
              hold-time 200)

            (defsrc
              a s d f j k l ;)

            ;; Homerow mods: tap for the letter, hold for the modifier.
            ;; Left hand:  a=Super s=Alt d=Ctrl f=Shift
            ;; Right hand: j=Shift k=Ctrl l=Alt ;=Super
            (defalias
              a (tap-hold $tap-time $hold-time a lmet)
              s (tap-hold $tap-time $hold-time s lalt)
              d (tap-hold $tap-time $hold-time d lctl)
              f (tap-hold $tap-time $hold-time f lsft)
              j (tap-hold $tap-time $hold-time j rsft)
              k (tap-hold $tap-time $hold-time k rctl)
              l (tap-hold $tap-time $hold-time l ralt)
              ; (tap-hold $tap-time $hold-time ; rmet))

            (deflayer base
              @a @s @d @f @j @k @l @;)
          '';
        };
      };
    };
  };
}
