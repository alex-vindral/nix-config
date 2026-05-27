{...}: {
  bungo.aspects.audio = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.wiremix];

      xdg.configFile."systemd/user/pipewire.service.d/zz-ladspa-path.conf".text = ''
        [Service]
        Environment=LADSPA_PATH=${pkgs.rnnoise-plugin}/lib/ladspa
      '';

      xdg.configFile."pipewire/pipewire.conf.d/99-rnnoise.conf".text = ''
        context.modules = [
          {
            name = libpipewire-module-filter-chain
            args = {
              node.description = "Noise Canceling Source"
              media.name        = "Noise Canceling Source"
              filter.graph = {
                nodes = [
                  {
                    type    = ladspa
                    name    = rnnoise
                    plugin  = "librnnoise_ladspa"
                    label   = noise_suppressor_mono
                    control = {
                      "VAD Threshold (%)"           = 50.0
                      "VAD Grace Period (ms)"       = 200
                      "Retroactive VAD Grace (ms)"  = 0
                    }
                  }
                ]
              }
              capture.props = {
                node.name   = "capture.rnnoise_source"
                node.passive = true
                audio.rate  = 48000
              }
              playback.props = {
                node.name   = "rnnoise_source"
                media.class = Audio/Source
                audio.rate  = 48000
              }
            }
          }
        ]
      '';
    };

    nixos = {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
    };
  };
}
