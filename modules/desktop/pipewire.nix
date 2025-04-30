{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    pulseaudio
    pw-volume
    qpwgraph
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };

  security.rtkit.enable = true;
}
